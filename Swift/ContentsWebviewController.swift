//
//  ContentsItemNotice.swift
//  DaeilIosApp
//
//  Created by 대일감정원 on 2018. 2. 22..
//  Copyright © 2018년 대일감정원. All rights reserved.
//

import Foundation
import WebKit
import Alamofire
import MessageUI
import SafariServices

class ContentsWebviewController : UIViewController, WKUIDelegate, WKNavigationDelegate, UIDocumentInteractionControllerDelegate,WKScriptMessageHandler, MFMessageComposeViewControllerDelegate{
   
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }

    

    var WebView: WKWebView!
    
    var idx:String = "";
    var SendURLINFO:String = "";
    var fileUrl:URL!;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        
        let webConfiguration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        contentController.add(self, name: "openUrl")  // JS에서 호출할 이름
        contentController.add(self, name: "DaeilApp")
        contentController.add(self, name: "DaeilAppCloser")
        webConfiguration.userContentController = contentController
        
        webConfiguration.processPool = WKProcessPool.shared
        WebView = WKWebView(frame: .zero, configuration: webConfiguration)
        WebView.uiDelegate = self;
        WebView.navigationDelegate = self;
        WebView.translatesAutoresizingMaskIntoConstraints = false;
        view.addSubview(WebView)
        NSLayoutConstraint.activate([
            WebView.topAnchor.constraint(equalTo: view.topAnchor),
            WebView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            WebView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            WebView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        print("ContentsWebview")
        print("ContentsWebview idx : \(idx)")
        guard let url = URL(string: idx) else { return  }
        var request = URLRequest(url: url)
        
   
        
        WebView.load(request);
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        let urlIndex = (navigationResponse.response.url?.description)!
        print("ContentsWebview response Decidepolicy")
        print(urlIndex)
        // 위에 didloadview 에서 직접 세션 넣는거 없으면 세션 로그인 못햇다고 나오고 여기로 나옴
        // 그리고 세션이 적용되는곳
//        let cook = WebView.configuration.websiteDataStore.httpCookieStore
//        HTTPCookieStorage.setWKCookie(wk: cook)
        
        if urlIndex == Config.baseURL + "/app/5_save.html"{
            print("세이브 되는 링크 들어와써?")
            //self.dismiss(animated: false, completion: nil)
        }else{
            
        }
        decisionHandler(.allow)
        
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("ContentsWebview decidePolicyFor")
        let curUrl = navigationAction.request.url!.absoluteString;
        
//        HTTPCookieStorage.shared.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.always;
        
        print("ContentsWebview decidePolicyFor curUrl : \(curUrl)")
        let cur = curUrl.split(separator: ":")
        print("ContentsWebview decidePolicyFor cur : \(cur)")
        // 전화 버튼 눌렀을때 딱히 중첩 안되서 그냥 넣음
        if cur[0] == "sms"{
            if !MFMessageComposeViewController.canSendText(){
                print("SMS SERVICES ARE NOT ABAILABLE")
            }else{
                // 메세지 표시
                let messageContent = cur[1].description
                let messageFinal : String? = messageContent.removingPercentEncoding
                
                let messageController = MFMessageComposeViewController()
                messageController.messageComposeDelegate = self
                messageController.body = messageFinal;
                self.present(messageController, animated: true, completion: nil)
            }
        }else if cur[0] == "tel"{
            let telnum = cur[1].description;
            print(telnum)
            if let phoneCallUrl = URL(string:"tel://\(telnum)"){
                let application:UIApplication = UIApplication.shared
                if (application.canOpenURL(phoneCallUrl)){
                    //일단 안들어옴
                    application.open(phoneCallUrl, options: [:], completionHandler: nil)
                }
            }
        }
        
        if curUrl.contains("opRpptView.htm"){
            print("opRpptView.html")
        }
//        else  if curUrl.contains("6_view")  {
//            print("📄 opRpptView.htm 발견됨, 이동 실행")
//            guard let url = URL(string:  curUrl) else { return  }
//            let request = URLRequest(url: url)
//            WebView.load(request)
//        }
        
        if CheckFlag.pushFlag == true {
            var oriUrl : String? =  nil
            var finalUrl : String? = nil
            CheckFlag.pushFlag = false
            
            oriUrl = Config.baseURL + "/app/9_view.html?"
            finalUrl = oriUrl! + CheckFlag.pushURL
            
            
            print("CheckFlag.pushLinkType  : \(finalUrl)")
            print("ContentsWebview decidePolicyFor pushFlag 있따");
            
            guard let url = URL(string:  finalUrl!) else { return  }
            var request = URLRequest(url: url)
            
            WebView.load(request);
            
        }
        
        // 이건 내부 글들 읽게 해야하는 url controll
        var indexUrl = curUrl.split(separator: "?")
        print(indexUrl);
        
        if indexUrl[0] == Config.baseURL + "/app/fileLoad.html"{
            print("ContentsWebview decidePolicyFor fileLoad");
          
            let extension4 = "\(curUrl)".suffix(4)
            let extension5 = "\(curUrl)".suffix(5)

            if FileTypeAll(four: String(extension4), five: String(extension5)){
                print("file Download TEST")
                let fileManager = FileManager.default
                let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                print(documentURL)
                let fileName = curUrl.split(separator: "=").last
                print(fileName!)
                let fileURL = documentURL.appendingPathComponent(String(fileName?.removingPercentEncoding! ?? "nil"))
                print(fileURL)
                
                let destination : DownloadRequest.Destination = {_, _ in return (fileURL, [.removePreviousFile, .createIntermediateDirectories])}
                
                AF.download(navigationAction.request.url!.absoluteString, method: .get, parameters: nil, encoding: JSONEncoding.default, to: destination).downloadProgress { (progress) in
                                print("progress: \(Int(progress.fractionCompleted * 100))")
                            }.response { response in
                                if response.error != nil {
                                    print("파일다운로드 실패")
                                } else {
                                    print("파일다운로드 완료")
                                    do{
                                        print(fileManager.fileExists(atPath: fileURL.path))
                                        if fileManager.fileExists(atPath: fileURL.path){
                                            if FileTypeRemoveHWP(four: String(extension4), five: String(extension5)){
                                                let viewer = UIDocumentInteractionController(url: fileURL)
                                                viewer.delegate = self
                                                viewer.presentPreview(animated: true)
                                            }else{
                                                print("한글 파일입니다.")
                                                self.createDaeilShare(fileURL)
                                            }
                                        }
                                    }catch{
                                        print("reed error")
                                    }
                                }
                            }
                            decisionHandler(.cancel)
                            return
            }else {
                let testUrl = URL(string:curUrl);
                print("다운로드")
                UIApplication.shared.open(testUrl!, options: [:], completionHandler: nil)
            }
            
            decisionHandler(.cancel)
            return;
        }else if curUrl == Config.baseURL + "/app/index.html"{
            // AppStartController 로 이동
            let nextIndexControllerView = storyboard?.instantiateViewController(withIdentifier:"appstart_controller");
            present(nextIndexControllerView!, animated: false, completion: nil);
            
        }
        
        decisionHandler(.allow)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(segue.destination);
        
        if let notice = segue.destination as? ContentsItemTaksangPrint{
            notice.idx = SendURLINFO;
        }else{
            print("etc")
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        print("javascript 1")


        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "확인", style: .cancel) { _ in
              completionHandler()
            }
            alertController.addAction(cancelAction)
            DispatchQueue.main.async {
              self.present(alertController, animated: true, completion: nil)
            }

//        self.present(alertController, animated: true, completion: nil)
    }
 
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {
        
        print("javascript 2")
        
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            completionHandler(true)
        }))
        alertController.addAction(UIAlertAction(title: "취소", style: .default, handler: { (action) in
            completionHandler(false)
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("ContentsWebviewController userContentController 📩 JS에서 받은 메시지: \(message.body)")
        
//        contentController.add(self, name: "openUrl")  // JS에서 호출할 이름
//        contentController.add(self, name: "DaeilApp")
//        contentController.add(self, name: "DaeilAppCloser")
        
        if message.name == "openUrl" {
            guard let urlString = message.body as? String,
                      let url = URL(string: urlString) else {
                    print("❌ 잘못된 URL")
                    return
                }
            
            print("ContentsWebview decidePolicyFor userContentController urlString : \(urlString)")
            
//            if urlString.contains("opRpptView.htm") || urlString.contains("4_edit") || urlString.contains("shop_view"){
//                print("📄 opRpptView.htm 발견됨, 이동 실행")
//                let request = URLRequest(url: url)
//                WebView.load(request)
//            } else
            if urlString.contains("http://218.153.71.28/login") || urlString.contains("https://m.biz.bearbetter.net/id201805") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)

            }else {
                let request = URLRequest(url: url)
                WebView.load(request)
            }
        }else if message.name == "DaeilApp" {
            do {
            
                guard let messageBody = message.body as? String else{return}
                guard let data = messageBody.data(using: .utf8) else {
                  return
                }
        
            
                let json:ImageInfo = try JSONDecoder().decode(ImageInfo.self, from: data)
                
                let jsonUri = json.uri
                let jsonName = json.name

                
                let realData = String(jsonUri.dropFirst(22))
                guard let decoded = Data(base64Encoded: realData) else {return}
                
                fileUrl = createDaeilFile(jsonName, decoded)
                
                createDaeilShare(fileUrl)
            } catch {
                print(error.localizedDescription)
            }
        }else if message.name == "DaeilAppCloser" {
            let backList = WebView.backForwardList.backList
            var url  = ""
            
            print("DaeilAppCloser backList : \(backList)")
            
            for item in backList {
                print("🔙 DaeilAppCloser 히스토리 URL:", item.url.absoluteString)
                url = item.url.absoluteString

            }
            
            if url.contains("6_view") {
                self.dismiss(animated: true)
            } else {
                if message.body as! String == "back" {
                    if WebView.canGoBack {
                        WebView.goBack()
                    } else {
                        // 웹 뒤로 갈 페이지 없으면 뷰컨트롤러 종료 등
                        self.dismiss(animated: true)
                    }
                }else {
                    self.dismiss(animated: true)
                }
            }
            
        }
        
        
    }
    
    private func createDaeilFile(_ file:String, _ contents: Data) -> URL{
        
        // FileManager 인스턴스 생성
        let fileManager: FileManager = FileManager.default
        // 사용자의 문서 경로
        let documentPath: URL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let folderPath = documentPath.appendingPathComponent("탁상")
        
        if !FileManager.default.fileExists(atPath: folderPath.path) {
            do {
                try FileManager.default.createDirectory(atPath: folderPath.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
            
        let filePath = folderPath.appendingPathComponent(file)
        fileManager.createFile(atPath: filePath.path, contents: contents)
        
        
        return filePath
        
    }
    
    func shareImage(_ image: UIImage, from viewController: UIViewController) {
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = viewController.view // iPad 대응
        viewController.present(activityVC, animated: true, completion: nil)
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        print("delete");
        
        // push 에서 들어오면 self.dismiss 가 먹히지 않는다.
        if webView == WebView{
            // 이건 완전 삭제
            //WebView.removeFromSuperview()
            
            if CheckFlag.pushFlag {
                print("2 in")
                CheckFlag.pushFlag = false
                
                //self.view.window?.rootViewController = self.view.window?.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "index_controller")
                return
            }
            CheckFlag.pushFlag = false
            
            print("1 in")
            self.dismiss(animated: true, completion: nil);
        }
    }
    
    private func createDaeilShare(_ file:URL){
        let fileURL = NSURL(fileURLWithPath: file.path)

        var filesToShare = [Any]()

        filesToShare.append(fileURL)

        let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)

        activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, activityError in
            
            if completed {
                print("COMPLETED: ", returnedItems)
            } else {
                print("FAILED: ", activityError.debugDescription)
            }
        }

        // Show the share-view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}
