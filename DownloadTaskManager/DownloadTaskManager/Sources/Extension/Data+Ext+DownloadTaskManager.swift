//
//
//  Workspace: DownloadTaskManager
//  MacOS Version: 11.4
//			
//  File Name: Data+Ext+DownloadTaskManager.swift
//  Creation: 5/31/21 7:09 PM
//
//  Author: Dragos-Costin Mandu
//
//
	

import Foundation
import CryptoKit

public extension Data
{
    
    /// The SHA1 hash string representation of the current Data.
    /// ```
    /// ATTENTION: Don't use it for cryptographic meanings.
    /// ```
    var sha1HashString: String
    {
        let digest = Insecure.SHA1.hash(data: self)
        
        return digest.map
        {
            String(format: "%02hhx", $0)
        }
        .joined()
    }
}
