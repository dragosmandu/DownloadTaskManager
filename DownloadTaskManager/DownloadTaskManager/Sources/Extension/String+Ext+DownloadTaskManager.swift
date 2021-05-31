//
//
//  Workspace: DownloadTaskManager
//  MacOS Version: 11.4
//			
//  File Name: String+Ext+DownloadTaskManager.swift
//  Creation: 5/31/21 7:09 PM
//
//  Author: Dragos-Costin Mandu
//
//


import Foundation

public extension String
{
    
    /// An empty String.
    static let sk_Empty: String = ""
    
    /// The SHA1 hash string representation of the current String.
    /// ```
    /// ATTENTION: Don't use it for cryptographic meanings.
    /// ```
    var sha1HashString: String?
    {
        var sha1HashString: String?
        
        if let data = self.data(using: .utf8)
        {
            sha1HashString = data.sha1HashString
        }
        
        return sha1HashString
    }
}
