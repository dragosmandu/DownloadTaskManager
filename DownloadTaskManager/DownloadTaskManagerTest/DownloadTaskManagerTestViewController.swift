//
//
//  Workspace: DownloadTaskManager
//  MacOS Version: 11.4
//			
//  File Name: DownloadTaskManagerTestViewController.swift
//  Creation: 5/31/21 7:17 PM
//
//  Author: Dragos-Costin Mandu
//
//


import UIKit
import DownloadTaskManager

class DownloadTaskManagerTestViewController: UIViewController, DownloadTaskDelegate
{
    private let m_DownloadTaskManager: DownloadTaskManager = .init()
    private let m_ImageView: UIImageView = .init()
    private let m_ImageUrl: URL = URL(string: "https://wallpaperplay.com/walls/full/8/0/2/101945.jpg")!
    
    init()
    {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        m_ImageView.translatesAutoresizingMaskIntoConstraints = false
        m_ImageView.contentMode = .scaleAspectFit
        
        view.addSubview(m_ImageView)
        
        NSLayoutConstraint.activate(
            [
                m_ImageView.widthAnchor.constraint(equalTo: view.widthAnchor),
                m_ImageView.heightAnchor.constraint(equalTo: view.heightAnchor)
            ]
        )
        
        m_DownloadTaskManager.delegate = self
        m_DownloadTaskManager.downloadFor(externalUrl: m_ImageUrl)
    }
    
    func didChangeDownloadProgress(_ downloadTaskManager: DownloadTaskManager, newDownloadProgress: Double)
    {
        print("Download progress: ", newDownloadProgress, "\n")
    }
    
    func didFinishDownload(_ downloadTaskManager: DownloadTaskManager, success: Bool)
    {
        if success
        {
            print("Download finished successfully")
            
            if let fileUrl = downloadTaskManager.currentFileUrl, let data = try? Data(contentsOf: fileUrl), let image = UIImage(data: data)
            {
                DispatchQueue.main.async
                {
                    self.m_ImageView.image = image
                }
            }
            else
            {
                print("Failed to create image")
            }
        }
        else
        {
            print("Download failed")
        }
    }
    
}

