//
//
//  Workspace: DownloadTaskManager
//  MacOS Version: 11.4
//			
//  File Name: DownloadTaskManager.swift
//  Creation: 5/31/21 7:08 PM
//
//  Author: Dragos-Costin Mandu
//
//


import UIKit
import os

public class DownloadTaskManager: NSObject
{
    // MARK: - Initialization
    
    public static var s_LoggerSubsystem: String = Bundle.main.bundleIdentifier!
    public static var s_LoggerCategory: String = "DownloadTaskManager"
    public static let s_Logger: Logger = .init(subsystem: s_LoggerSubsystem, category: s_LoggerCategory)
    
    public var delegate: DownloadTaskDelegate? = nil
    
    /// The local file URL that was downloaded in the last download session.
    public private(set) var currentFileUrl: URL? = nil
    
    /// The external URL of the current download session.
    public private(set) var currentExternalUrl: URL? = nil
    public private(set) var isDownloading: Bool = false
    
    private var m_Session: URLSession!
    private var m_Task: URLSessionDownloadTask?
    private var m_ResumeData: Data?
    
    public override init()
    {
        super.init()
        
        m_Session = .init(configuration: .default, delegate: self, delegateQueue: nil)
    }
    
    deinit
    {
        if let session = m_Session
        {
            session.invalidateAndCancel()
        }
    }
}

extension DownloadTaskManager
{
    // MARK: - Methods
    
    /// Checks the Cache directory for the file under the given external URL, if it doesn't exist, will start downloading it async.
    /// ```
    /// New downloads will cancel tasks that are currently in progress.
    /// ```
    public func downloadFor(externalUrl: URL)
    {
        
        // Cancels the current download task with resume data, if any.
        m_Task?.cancel(byProducingResumeData:  { _ in })
        
        isDownloading = true
        
        if let cachedFileUrl = FileManager.searchCache(externalUrl: externalUrl)
        {
            DownloadTaskManager.s_Logger.debug("Item found in Cache at: \(cachedFileUrl.absoluteString).")
            
            currentFileUrl = cachedFileUrl
            currentExternalUrl = externalUrl
            
            // Tells the delegate the download finished and the file can be used.
            finishedCurrentDownloadWith(success: true, errorDesc: nil)
        }
        else
        {
            if let resumeData = m_ResumeData, currentExternalUrl == externalUrl
            {
                DownloadTaskManager.s_Logger.debug("Item resumed download with: \(resumeData.count) bytes.")
                
                // Resumes the download task with the downloaded resume Data if it's the same endpoint.
                m_Task = m_Session.downloadTask(withResumeData: resumeData)
            }
            else
            {
                DownloadTaskManager.s_Logger.debug("Download started for: \(externalUrl.absoluteString).")
                
                // Create a new download task for the new URL.
                m_Task = m_Session.downloadTask(with: externalUrl)
            }
            
            currentExternalUrl = externalUrl
            m_Task?.resume()
        }
    }
    
    /// Cancels the current download task immediatelly, with resume data.
    public func cancelCurrentDownload()
    {
        m_ResumeData = nil
        isDownloading = false
        
        m_Task?.cancel(byProducingResumeData:  { _ in })
    }
    
    private func finishedCurrentDownloadWith(success: Bool, errorDesc: String?)
    {
        if !success || errorDesc != nil
        {
            DownloadTaskManager.s_Logger.log("Download failed for '\(self.currentExternalUrl?.absoluteString ?? "")'\(errorDesc != nil ? " with error '\(errorDesc!)'" : "").")
        }
        else
        {
            DownloadTaskManager.s_Logger.debug("Download finished successfully for '\(self.currentExternalUrl?.absoluteString ?? "")'.")
            
            m_ResumeData = nil // Resume data may be discarded as the download succedded.
        }
        
        isDownloading = false
        delegate?.didFinishDownload(self, success: success)
    }
}

extension DownloadTaskManager: URLSessionDownloadDelegate, URLSessionTaskDelegate
{
    // MARK: - URLSessionDownloadDelegate, URLSessionTaskDelegate
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL)
    {
        var success = false
        
        // Cache the file for the current external URL, were it was downloaded from.
        if let externalUrl = currentExternalUrl, let cachedFileURL = FileManager.cacheFile(fileUrl: location, externalUrl: externalUrl)
        {
            currentFileUrl = cachedFileURL
            success = true
        }
        
        finishedCurrentDownloadWith(success: success, errorDesc: nil)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
    {
        guard let error = error else { return }
        let userInfo = (error as NSError).userInfo
        
        if let resumeData = userInfo[NSURLSessionDownloadTaskResumeData] as? Data
        {
            m_ResumeData = resumeData
        }
        
        finishedCurrentDownloadWith(success: false, errorDesc: error.localizedDescription)
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
    {
        if totalBytesExpectedToWrite != NSURLSessionTransferSizeUnknown
        {
            let newDownloadProgress = Double(totalBytesWritten * 100) / Double(totalBytesExpectedToWrite)
            
            delegate?.didChangeDownloadProgress(self, newDownloadProgress: newDownloadProgress)
        }
    }
}
