//
//
//  Workspace: DownloadTaskManager
//  MacOS Version: 11.4
//			
//  File Name: DownloadTaskManagerDelegate.swift
//  Creation: 5/31/21 7:08 PM
//
//  Author: Dragos-Costin Mandu
//
//


import UIKit

public protocol DownloadTaskDelegate
{
    
    /// Called every time current download has changed progress.
    /// - Parameters:
    ///   - downloadTaskManager: The DownloadTaskManager object used for the download.
    ///   - newDownloadProgress: The new progress percentage for the current download.
    func didChangeDownloadProgress(_ downloadTaskManager: DownloadTaskManager, newDownloadProgress: Double)
    
    /// Called when the current download has finished, successfully or not.
    /// - Parameters:
    ///   - downloadTaskManager: The DownloadTaskManager object used for the download.
    ///   - success: True if the download has been succeeded, false otherwise.
    func didFinishDownload(_ downloadTaskManager: DownloadTaskManager, success: Bool)
}
