//
//  WebViewController.swift
//  OnTheMap
//
//  Copied from John Bateman.


import UIKit
import WebKit

class WebViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    
    var webView: WKWebView?
    var url: String?
    
    override func loadView() {
        super.loadView()
        
        // create a WKWebView
        self.webView = WKWebView()
        
        // assign the WKWebView to the view controller's view
        self.view = self.webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUrl(url)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* 
    @brief Load the web page identified by the url parameter in the WKWebView
    @param (in) url - The web page to display.
    */
    func loadUrl(url: String?) {
        if let url = url {
            let nsurl = NSURL(string:url)
            if let nsurl = nsurl {
                let request = NSURLRequest(URL:nsurl)
                self.webView!.loadRequest(request)
            }
        }
    }
}
