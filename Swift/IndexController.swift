//
//  IndexController.swift
//  DaeilIosApp
//
//  Created by 대일감정원 on 2018. 2. 9..
//  Copyright © 2018년 대일감정원. All rights reserved.
//

import Foundation
import WebKit
import Alamofire

class IndexController : UIViewController, WKNavigationDelegate, WKUIDelegate, UIDocumentInteractionControllerDelegate,WKScriptMessageHandler{
    
    
   
    var WebView: WKWebView!
    @IBOutlet weak var DownButton: UIButton!
    
    
    @IBOutlet weak var indexView: UIView!
    @IBOutlet weak var UpImage: UIImageView!
    
    @IBOutlet weak var DownImage: UIImageView!
    @IBOutlet weak var UpButton: UIButton!
    @IBOutlet weak var MenuBar: UIView!
    
    @IBOutlet weak var UpbarBtnSurvey: UIButton!
    @IBOutlet weak var UpbarBtnModify: UIButton!
    @IBOutlet weak var UpbarBtnExit: UIButton!
    
    @IBOutlet var IndexControllerView: UIView!
    
    var SendURLINFO:String = "";
    var SendBANKINFO:String = "";
    
    var viewtype = ""
    var idx=""
    
    static var TripCheckFlag : Bool =  false;
    
    
    var url : URL? = nil
    var request : URLRequest? = nil;
    
    private let greenView = UIView()
    
//    override func loadView() {
//        super.loadView()
//        print("1111111111111111111111 : IndexController loadView")
//        print(WebView.safeAreaInsets.top)
//        print(indexView.safeAreaInsets.top)
//   }

    override func viewDidLoad() {
        super.viewDidLoad();
        NetworkManager.shared.startMonitoring()
        print("2222222222222222222222 : IndexController viewDidLoad")
        
//        self.definesPresentationContext = true
        
        CheckFlag.modifyFlag = false
        
        WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                WKWebsiteDataStore.default().httpCookieStore.delete(cookie)
            }
        }
        
        let dataStore = WKWebsiteDataStore.default()

        let dataTypes: Set<String> = [
            WKWebsiteDataTypeMemoryCache,
            WKWebsiteDataTypeDiskCache,
            WKWebsiteDataTypeCookies,
            WKWebsiteDataTypeSessionStorage,
            WKWebsiteDataTypeLocalStorage,
            WKWebsiteDataTypeIndexedDBDatabases,
            WKWebsiteDataTypeWebSQLDatabases
        ]

        // 시간 기준 (모든 캐시 삭제)
        let dateFrom = Date(timeIntervalSince1970: 0)

        dataStore.removeData(ofTypes: dataTypes, modifiedSince: dateFrom) {
            print("✅ WebView 캐시 삭제 완료")
        }
        
        //let url = URL(string: Config.baseURL + "/app/")
        //var request = URLRequest(url: url!);
        
        var urlString = Config.baseURL + "/app/1.html?id=0"
        
       
        self.url = URL(string: urlString)
        
        print("request IndexController viewDidLoad :\(urlString)")
        self.request = URLRequest(url: self.url!)
        
        
        DownButton.isHidden = true
        DownImage.isHidden = true
        MenuBar.isHidden = true
        UpButton.isHidden = true
        UpImage.isHidden = true
//        DownImage.image = UIImage(named: "img_top_bar_show.png")
      

        // iphone 사이즈 체크 및 가로 세로 체크
        let ScrennFlag = CheckFlag.isiPhoneXScreen()
        
        
        
        // 아이폰X 일때
        if ScrennFlag {
            print("button location inininin??")
            // DownButton 위치 재조정
            //print("chage Height")
//            for constraint in self.view.constraints{
//                print(constraint.identifier?.description)
//                if constraint.identifier == "index_down_btn" {
//                    print("index_down_btn")
//                    constraint.constant = 50;
//                }
//            }
            
            let margin = IndexControllerView.layoutMarginsGuide
            let top = DownButton.layer.frame.height
            //print("top :  \(top)")

            DownButton.heightAnchor.constraint(equalTo: margin.heightAnchor, multiplier: 0.1, constant: -4.0).isActive = true;
            UpButton.heightAnchor.constraint(equalTo: margin.heightAnchor, multiplier: 0.1, constant: -4.0).isActive = true;

        }

        let contentController = WKUserContentController()
        contentController.add(self, name: "openUrl")  // JS에서 호출할 이름
        contentController.add(self, name: "DaeilAppCloser")
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        
        WebView = WKWebView(frame: self.indexView.frame, configuration: config)
        WebView.uiDelegate = self
        WebView.navigationDelegate = self
        WebView.translatesAutoresizingMaskIntoConstraints = false
        self.indexView.addSubview(WebView)
        
        NSLayoutConstraint.activate([
            WebView.topAnchor.constraint(equalTo: indexView.topAnchor),
            WebView.bottomAnchor.constraint(equalTo: indexView.bottomAnchor),
            WebView.leadingAnchor.constraint(equalTo: indexView.leadingAnchor),
            WebView.trailingAnchor.constraint(equalTo: indexView.trailingAnchor)
        ])
        
        WebView.load(self.request!)
        
        

    }

    override func viewWillAppear(_ animated: Bool) {
        //print("view가 실행하려고 한다아아아아아아")
        
        print("333333333333333333333 : IndexController viewWillAppear")
        
        if CheckFlag.Flag == true{
            WebView.reload();
            CheckFlag.saveTripCheckFlag(flag: false)
            //IndexController.TripCheckFlag = false;
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("4444444444444444444444 : IndexController viewDidAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("5555555555555555555555 : IndexController. viewWillDisappear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("6666666666666666666666 : IndexController viewDidDisappear")
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        //        print("6666666666666666666666 : IndexController userContentController WKUserContentController")
        
        let storyboard2: UIStoryboard? = UIStoryboard(name: "Main", bundle: nil)
        print(" IndexController userContentController 📩 JS에서 받은 메시지: \(message.body)")
        if message.name == "openUrl" {
            
            guard let urlString = message.body as? String,
                  let url = URL(string: urlString) else {
                print("❌ 잘못된 URL")
                return
            }
            print("ContentsWebview decidePolicyFor userContentController urlString : \(urlString)")
            
            if urlString.starts(with: "camera") {
                // 여기서 camera 호출 감지됨!
                print("🎥 [감지] camera 호출됨! ✅")
                // 파라미터 추출 (선택)
                let queryString = urlString.replacingOccurrences(of: "camera?", with: "")
                let params = queryString.components(separatedBy: "&")
                
                var idx: String?
                var bankTy: String?
                
                for param in params {
                    let pair = param.components(separatedBy: "=")
                    if pair.count == 2 {
                        if pair[0] == "idx" {
                            idx = pair[1]
                        } else if pair[0] == "bank_ty" {
                            bankTy = pair[1]
                        }
                    }
                }
                
                print("📦 idx: \(idx ?? "없음"), bank_ty: \(bankTy ?? "없음")")
                
                
                
                SendURLINFO = idx!.description.base64Decoded()!
                if bankTy!.isEmpty {
                    SendBANKINFO = "000000"
                }else{
                    SendBANKINFO = bankTy!
                }
                
                print(SendBANKINFO)
                
                HTTPCookieStorage.save()
                performSegue(withIdentifier: "idxSegueField", sender: self)
                
                // 예: 해당 값으로 카메라 띄우거나 다음 화면 이동
                
            }else if urlString.contains("http://218.153.71.28/login") || urlString.contains("https://m.biz.bearbetter.net/id201805") || urlString.contains("/ndab/") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                
                //                let safariVC = SFSafariViewController(url: url)
                //                present(safariVC, animated: true, completion: nil)
            }else if urlString.contains("setting") {
                performSegue(withIdentifier: "modifySegue", sender: self)
            }else if urlString.contains("MobileLogout") {
                powerOff()
            }
            else {
                if let storyboard2 = UIStoryboard(name: "Main", bundle: nil) as UIStoryboard?,
                   let nextIndexControllerView = storyboard2.instantiateViewController(withIdentifier: "contents_webpage") as? ContentsWebviewController {
                    
                    nextIndexControllerView.idx = urlString
                    present(nextIndexControllerView, animated: true, completion: nil)
                }
            }
        }else if message.name == "DaeilAppCloser" {
            //
            if WebView.canGoBack {
                WebView.goBack()
            } else {
                // 웹 뒤로 갈 페이지 없으면 뷰컨트롤러 종료 등
                self.dismiss(animated: true)
            }
        }
    }
    

    
    // javascript alert 띄워주는 쪽 이거 근데 기본이 base64 로 되어있어서 문제가 클듯 javascript
    // alert 쪽은 잘 안쓸 예정
    
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
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Void) {
        
        print("javascript 3")
        
        let alertController = UIAlertController(title: "", message: prompt, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.text = defaultText
        }
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "취소", style: .default, handler: { (action) in
            completionHandler(nil)
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("webview start")
        /*
        if CheckFlag.pushFlag {
            if CheckFlag.pushLinkType == "1"{
                print("push 1")
                CheckFlag.pushFlag = false
                SendURLINFO = CheckFlag.pushURL;
                performSegue(withIdentifier: "idxSegueNotice", sender: self)
            }else if CheckFlag.pushLinkType == "2"{
                print("push 2")
                CheckFlag.pushFlag = false
                SendURLINFO = CheckFlag.pushURL
                performSegue(withIdentifier: "idxSegueMessage", sender: self)
            }else if CheckFlag.pushLinkType == "3"{
                print("push 3")
                CheckFlag.pushFlag = false
                SendURLINFO = CheckFlag.pushURL
                performSegue(withIdentifier: "idxSegueEvaluate", sender: self)
            }else if CheckFlag.pushLinkType == "4"{
                print("push 4")
                CheckFlag.pushFlag = false
                SendURLINFO = CheckFlag.pushURL
                performSegue(withIdentifier: "idxSegueTaksang", sender: self)
            }else if CheckFlag.pushLinkType == "5"{
                print("push 5")
                CheckFlag.pushFlag = false
                SendURLINFO = CheckFlag.pushURL
                performSegue(withIdentifier: "idxSegueTrip", sender: self)
            }else{
                print("혹시나")
            }
        }*/
        
//        if CheckFlag.pushFlag{
//            CheckFlag.pushFlag = false;
//            SendURLINFO = CheckFlag.pushURL
//            performSegue(withIdentifier: "idxSeguePush", sender: self)
//        }
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("webview end");
        // 알람이 처음 시작할때
        
        // 여기서 Push가 true / false 인지 체크한다.
        /*
        if(CheckFlag.pushFlag){
            print("PUSH_PUSH_PUSH===========================================")
        }*/
    }
    
    
    /*
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Swift.Void) {
        guard
            let response = navigationResponse.response as? HTTPURLResponse,
            let url = navigationResponse.response.url
            else {
                decisionHandler(.cancel)
                return
        }
        
        if let headerFields = response.allHeaderFields as? [String: String] {
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url)
            cookies.forEach { (cookie) in
                print(cookie)
                HTTPCookieStorage.shared.setCookie(cookie)
            }
        }
        
        decisionHandler(.allow)
    }
 */
    /*
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        print("navigationResponse")
        //print(navifation)
        let url = navigationResponse.response.url?.description
        if url == Config.baseURL + "/app/"{
            print("아직 세션 붙지 않음")
            let nextIndexControllerView = storyboard?.instantiateViewController(withIdentifier:"index_controller");

            present(nextIndexControllerView!, animated: false, completion: nil);
        }else if url == Config.baseURL + "/app/index.html"{
            let nextIndexControllerView = storyboard?.instantiateViewController(withIdentifier:"index_controller");

            present(nextIndexControllerView!, animated: false, completion: nil);
        }else {
//            print("21498327114598275982347598743985")
            print("세션 붙음")
        }

        decisionHandler(.allow)
    }*/
    
    // 이 함수 안에서 데이터를 다음 VC에 전달
       
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        print("navigationResponse")
        //print(navifation)
        
        HTTPCookieStorage.shared.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.always
        let cook = WebView.configuration.websiteDataStore.httpCookieStore
        //HTTPCookieStorage.setWKCookie(wk: cook)
        
        if CheckFlag.pushFlag{
            print("ININININI????")
            CheckFlag.pushFlag = false;
            SendURLINFO = CheckFlag.pushURL
            performSegue(withIdentifier: "idxSeguePush", sender: self)
        }
        
        
        
        let url = navigationResponse.response.url?.description
        print("request IndexController decidePolicyFor :\(url)")
        
        if url == Config.baseURL + "/app/"{
            print("아직 세션 붙지 않음")
            
//            webView.stopLoading()
//            print(CheckFlag.modifyFlag.description)
//            
//            let alertController = UIAlertController(title: "세션이 종료되었습니다. Application을 다시 실행 해주세요.", message: "", preferredStyle : .alert);
//
//            let okAction = UIAlertAction(title:"확인", style: UIAlertActionStyle.default){
//                UIAlertAction in
//
//                CheckFlag.modifyFlag = true
//                self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)
//                
////                self.view.window?.rootViewController = self.view.window?.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "index_controller")
//            }
//            alertController.addAction(okAction)
//            self.present(alertController, animated: true, completion: nil)
            
            
            
        }else if url == Config.baseURL + "/app/index.html"{
            // 로그인 화면
        }else {
            //print("21498327114598275982347598743985")
            print("세션 붙음")
            
            //webView.reload()
            
            // FOR PUSH MESSAGE
//            if CheckFlag.pushFlag {
//                if CheckFlag.pushLinkType == "1"{
//                    print("push 1")
//                    //CheckFlag.pushFlag = false
//                    SendURLINFO = CheckFlag.pushURL;
//                    performSegue(withIdentifier: "idxSegueNotice", sender: self)
//                }
//            }
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("decidePolicyfor webview")
        
        print(navigationAction.request.url!.absoluteString)
        
        //HTTPCookieStorage.shared.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.always;
        let cook = WebView.configuration.websiteDataStore.httpCookieStore
        
        print(cook)
        
        HTTPCookieStorage.setWKCookie(wk: cook)
        
        //
        //        let cook = WebView.configuration.websiteDataStore.httpCookieStore
        //        if let cookies = UserDefaults.standard.value(forKey: "cookies") as? [[HTTPCookiePropertyKey : Any]] {
        //            for cookie in cookies {
        //                if let oldCookie = HTTPCookie(properties: cookie) {
        //                    print("index  webview:\(oldCookie.name) : \(oldCookie.value)")
        //                    //print("**************************************************************")
        //                    cook.setCookie(oldCookie)
        //                }
        //            }
        //        }
        
        //        var cookies = HTTPCookie.requestHeaderFields(with: HTTPCookieStorage.shared.cookies(for: (self.request?.url)!)!)
        //
        //        if let value = cookies["Cookie"]{
        //            print("test : \(value)")
        //            self.request?.addValue(value, forHTTPHeaderField: "cookie")
        //        }
        
        
        
        
        let curUrl = navigationAction.request.url!.absoluteString
        print("전체 curUrl : \(curUrl)")
        
        //print(curUrl)
        let cur = curUrl.split(separator: ":")
        
        // 전화 버튼 눌렀을때 딱히 중첩 안되서 그냥 넣음
        if cur[0] == "tel"{
            let telnum = cur[1].description
            //print(telnum)
            if let phoneCallUrl = URL(string:"tel://\(telnum)"){
                let application:UIApplication = UIApplication.shared
                if (application.canOpenURL(phoneCallUrl)){
                    //일단 안들어옴
                    application.open(phoneCallUrl, options: [:], completionHandler: nil)
                }
            }
        }
        
        // 이건 내부 글들 읽게 해야하는 url controll
        var indexUrl = curUrl.split(separator: "?")
        print(curUrl)
        print("\(indexUrl)  푸시 테스트를 위해서 여기에서 확인 확인 확인");
        
        // 여기서 URL 컨트롤 해서 해당 뷰 보여주기r
        if curUrl == "http://218.153.71.28/login"{
            //2021.09.29 수정
            /*let nextIndexControllerView = storyboard?.instantiateViewController(withIdentifier:"topmenu_parking");
             present(nextIndexControllerView!, animated: true, completion: nil);*/
            if let url = URL(string: "http://218.153.71.28/login"){
                UIApplication.shared.open(url, options: [:])
            }
        }else if curUrl == "https://m.biz.bearbetter.net/id201805"{
            //2021.09.29 수정
            /*let nextIndexControllerView = storyboard?.instantiateViewController(withIdentifier:"topmenu_parking");
             present(nextIndexControllerView!, animated: true, completion: nil);*/
            if let url = URL(string: "https://m.biz.bearbetter.net/id201805"){
                UIApplication.shared.open(url, options: [:])
            }
        }
        
//        else if indexUrl[0] == Config.baseURL + "/app/poll_view.html"{
//            //let nextIndexControllerView = storyboard?.instantiateViewController(withIdentifier:"contents_item_poll");
//            let idxTmp:String = indexUrl[1].description;
//            SendURLINFO = idxTmp
//            
//            performSegue(withIdentifier: "idxSeguePoll", sender: self)
//            //present(nextIndexControllerView!, animated: true, completion: nil)
//        }else if indexUrl[0] == Config.baseURL + "/app/8_view.html"{
//            let idxTmp:String = indexUrl[1].description;
//            SendURLINFO = idxTmp
//            performSegue(withIdentifier: "idxSegueDocument", sender: self)
//        }else if indexUrl[0] == Config.baseURL + "/app/1_view.html"{
//            let idxTmp:String = indexUrl[1].description;
//            print("test \(idxTmp)")
//            SendURLINFO = idxTmp;
//            //Send Data at Different controller
//            performSegue(withIdentifier: "idxSegueNotice", sender: self)
//            // 뒤 URL 정보 보내기
//            //self.performSegue(withIdentifier: "idxSegue", sender: nil)
//            //performSegue(withIdentifier: "idxSegue", sender: self)
//        }else if indexUrl[0] == Config.baseURL + "/app/2_view.html"{
//            let idxTmp:String = indexUrl[1].description;
//            SendURLINFO = idxTmp;
//            performSegue(withIdentifier: "idxSegueMessage", sender: self)
//        }else if indexUrl[0] == Config.baseURL + "/app/3_view.html"{
//            let idxTmp:String = indexUrl[1].description;
//            SendURLINFO = idxTmp;
//            performSegue(withIdentifier: "idxSegueEvaluate", sender: self)
//        }else if indexUrl[0] == Config.baseURL + "/app/4_view.html"{
//            let idxTmp:String = indexUrl[1].description;
//            SendURLINFO = idxTmp;
//            performSegue(withIdentifier: "idxSegueTaksang", sender: self)
//        }else if indexUrl[0] == Config.baseURL + "/app/5_view.html"{
//            let idxTmp:String = indexUrl[1].description;
//            SendURLINFO = idxTmp;
//            print(idxTmp)
//            //HTTPCookieStorage.save();
//            performSegue(withIdentifier: "idxSegueTrip", sender: self)
//        }else if indexUrl[0] == Config.baseURL + "/app/6_view.html"{
//            let idxTmp:String = indexUrl[1].description;
//            SendURLINFO = idxTmp;
//            print(idxTmp)
//            //HTTPCookieStorage.save();
//            performSegue(withIdentifier: "payment", sender: self)
//        }else if indexUrl[0] == Config.baseURL + "/app/9_view.html"{
//            let idxTmp:String = indexUrl[1].description;
//            SendURLINFO = idxTmp;
//            performSegue(withIdentifier: "idxSegueAlarm", sender: self)
//        }
        
        else if indexUrl[0] == Config.baseURL + "/app/fileLoad.html"{
            //print("fileLoad");
            //let idxTmp:String = indexUrl[1].description;
            //SendURLINFO = idxTmp;
            //performSegue(withIdentifier: "fileloadSegue", sender: self)
            
            // 여긴 일단 임시로 웹 URL로 해서 띄워줬음
            // 이거 두개
            //let testUrl = URL(string:curUrl);
            print("다운로드")
            //UIApplication.shared.open(testUrl!, options: [:], completionHandler: nil)
            
            print(curUrl)
            
            let extension4 = "\(curUrl)".suffix(4)
            let extension5 = "\(curUrl)".suffix(5)
            
            //print(FileType(four: String(extension4), five: String(extension5)))
            
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
        }else if indexUrl[0] == Config.baseURL + "/app/push.html"{
           // 여기 딱히 필요없겠다.
            
            
        }else if indexUrl[0] == Config.baseURL + "/app/attach.html"{
            //let idxTmp:String = indexUrl[1].description;
            //let idxTmp2 = idxTmp.split(separator: "=")
            //let idxFinal:String = idxTmp2[1].description
            //let idx:String = idxFinal.base64Decoded()!;
            
            //let idxTmp:String = indexUrl[1].description;
            //let idxTmp2 = idxTmp.split(separator: "=");
            //let idxTmp3 = idxTmp2[1].split(separator: "&");
            //let idxFinal:String = idxTmp3[0].description
            //let idx:String = idxFinal.base64Decoded() ?? "NULL";
            
           
          
            //let infoTmp:String = indexUrl[1].description;
            //let devideTmp = infoTmp.split(separator: "&");
            //print(devideTmp[0])
            //let idxTmp = devideTmp[0].split(separator: "=")
            
            //print(devideTmp.count)
            //if devideTmp.count == 1{
            //    print("11111");
            //}else{
            //    let bankTmp = devideTmp[1].split(separator: "=")
                
             //   if(bankTmp.count == 1){
                    
            //        SendBANKINFO = "000000"
            //    }else{
            //        SendBANKINFO = bankTmp[1].description
            //    }
            //}
                
            //SendURLINFO = idxTmp[1].description.base64Decoded()!

            
//            HTTPCookieStorage.save()
//            performSegue(withIdentifier: "idxSegueField", sender: self)
        }else if curUrl == Config.baseURL + "/app/index.html"{
            
            // 세션 종료시 재접속
            self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)
//            let cook = WebView.configuration.websiteDataStore.httpCookieStore
//
//            if let cookies = UserDefaults.standard.value(forKey: "cookies") as? [[HTTPCookiePropertyKey : Any]] {
//                for cookie in cookies {
//                    if let oldCookie = HTTPCookie(properties: cookie) {
//                        //print("테스트 webview1:\(oldCookie)")
//                        //print("================================================")
//                        //HTTPCookieStorage.shared.setCookie(oldCookie)
//                        //cook.setCookie(oldCookie)
//                        HTTPCookieStorage.clear()
//
//                        // 이건 쿠키 삭제
//                        cook.delete(oldCookie)
//                    }
//                }
//            }
            
//            if let cookies = UserDefaults.standard.value(forKey: "cookies") as? [[HTTPCookiePropertyKey : Any]] {
//                for cookie in cookies {
//                    if let oldCookie = HTTPCookie(properties: cookie) {
//                        //이게 있어야 초기화가 되는데??
//                        print("테스트 webview2 이게 왜 있어야 되나...ㅡ,,ㅡ");
//                    }
//                }
//            }
            
            // AppStartController 로 이동
//            let nextIndexControllerView = storyboard?.instantiateViewController(withIdentifier:"appstart_controller");
//            present(nextIndexControllerView!, animated: false, completion: nil);
            
            //self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)
        }else if curUrl == Config.baseURL + "/app/"{
//            let cook = WebView.configuration.websiteDataStore.httpCookieStore
            //HTTPCookieStorage.setWKCookie(wk: cook)
            print("****************************************************************")
            
            // indexviewcontroller 세션 연결 부분
            //let cook = WebView.configuration.websiteDataStore.httpCookieStore
            //HTTPCookieStorage.setWKCookie(wk: cook)
            
            
            // 수정 버튼을 눌렀을때
            // 안전 방지책
//            if(CheckFlag.modifyFlag){
//                print("MODIFT button URL")
//                self.url = URL(string: Config.baseURL + "/app/")
//                self.request = URLRequest(url: self.url!)
//
//                WebView.uiDelegate = self;
//                WebView.navigationDelegate = self;
//                WebView.translatesAutoresizingMaskIntoConstraints = false;
//
//                WebView.load(self.request!);
//
//                CheckFlag.modifyFlag = false;
//                print("after modify url : \(navigationAction.request.url?.description ?? "xxxx")")
//            }
            

        }else if curUrl == Config.baseURL + "/app/1.html?id=0"{
            print("main 화면으로 들어왔습니다.")
        }else if indexUrl[0] == Config.baseURL + "/app/1.html"{
            print("1111")
        }else if indexUrl[0] == Config.baseURL + "/app/2.html"{
            print("2222")
//            if let cookies = UserDefaults.standard.value(forKey: "cookies") as? [[HTTPCookiePropertyKey : Any]] {
//
//                for cookie in cookies {
//                    if let oldCookie = HTTPCookie(properties: cookie) {
//                        print("Test  webview info :\(oldCookie.name) : \(oldCookie.value)")
//                    }
//                }
//            }
        }else if indexUrl[0] == Config.baseURL + "/app/3.html"{
            print("3333")
        }else if indexUrl[0] == Config.baseURL + "/app/4.html"{
            print("4444")
        }else if indexUrl[0] == Config.baseURL + "/app/5.html"{
            print("5555")
        }else{
            // 아직 푸시쪽, 현장조자서 쪽 링크쪽 필요
        }
        
        // 여기 까지//
        
        // 이건 뭘하는 건지 모르겠다..
//        if ((curUrl.range(of: "phobos.apple.com") != nil) || (curUrl.range(of: "itunes.apple.com") != nil)){
//            //goOtherView(navigationAction.request)
//            decisionHandler(.cancel)
//            return
//        }else if((curUrl.hasPrefix("http")) || (curUrl.hasPrefix("https")) || (curUrl.hasPrefix("about")) || (curUrl.hasPrefix("file"))){
//
//        }else{
//            let strUrl2:String = Config.baseURL + "/app/comp.html"
//            if let strUrl1:URL = URL(string:strUrl2) {
//                if #available(iOS 10.0, *) {
//                    UIApplication.shared.open(strUrl1, options: [:], completionHandler: {
//                        (success) in
//                        //print("Open \(scheme): \(success)")
//                    })
//                } else {
//                    // Fallback on earlier versions
//                    UIApplication.shared.openURL(strUrl1)
//                }
//                decisionHandler(.cancel)
//                return
//            }
//
//        }
    
        
        // 이거 없으면 종료인데 뭔지 모르겟음.(정상적인 종료를 했는지 안했는지 webView fuc에서 return 같은 기능)
        decisionHandler(.allow)
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
    
    public func clearValues(){
        SendURLINFO = ""
        idx = ""
        viewtype = ""
    }
    
    
    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        // 중복적으로 리로드가 일어나지 않도록 처리 필요.
        webView.reload()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //print(segue.destination);
        
        if let notice = segue.destination as? ContentsItemNotice{
            notice.idx = SendURLINFO
        }else if let message = segue.destination as? ContentsItemMessage{
            message.idx = SendURLINFO
        }else if let evaluate = segue.destination as? ContentsItemEvaluate{
            evaluate.idx = SendURLINFO
        }else if let taksang = segue.destination as? ContentsItemTaksang{
            taksang.idx = SendURLINFO
        }else if let loadfile = segue.destination as? ContentsItemFileload{
            loadfile.idx = SendURLINFO
        }else if let trip = segue.destination as? ContentsItemTrip{
            trip.idx = SendURLINFO
        }else if let alarm = segue.destination as? ContentsItemAlarm{
            alarm.idx = SendURLINFO
        }else if let poll = segue.destination as? ContentsItemPoll{
            poll.idx = SendURLINFO
        }else if let push = segue.destination as? ContentsItemPush{
            push.idx = SendURLINFO
        }else if let field = segue.destination as? FieldSurveyController{
            // 이거 Base64로 디코드 해야함
            field.APNO = SendURLINFO
            field.BANKCODE = SendBANKINFO
        }else if let wkwebview = segue.destination as? ModifyController{
            wkwebview.WebView = WebView
        }else if let document = segue.destination as? ContentsItemDocument{
            document.idx = SendURLINFO
        }else if let document = segue.destination as? Contentsltempayment{
            document.idx = SendURLINFO
        }else{
            print("etc")
        }
        
//        if segue.identifier == "contents_webpage" {
//            if let nextVC = segue.destination as? ContentsWebviewController {
//                nextVC.idx = idx
//            }
//        }
        
        

    }
    
    
    // cookie 처리
    /*func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let headerKeys = navigationAction.request.allHTTPHeaderFields?.keys
        let hasCookies = headerKeys?.contains("Cookie") ?? false
        
        print("test")
        print(hasCookies)
        
        if hasCookies {
            decisionHandler(.allow)
        } else {
            let cookies = HTTPCookie.requestHeaderFields(with: HTTPCookieStorage.shared.cookies ?? [])
            print(cookies)
            
            var headers = navigationAction.request.allHTTPHeaderFields ?? [:]
            //headers += cookies
            //print(headers)
            
            var req = navigationAction.request
            req.allHTTPHeaderFields = headers
            
            webView.load(req)
            
            decisionHandler(.cancel)
        }
    }*/
    
    @IBAction func DownButtonAction(_ sender: Any) {
        DownButton.isHidden = true
        DownImage.isHidden = true
        MenuBar.isHidden = false
        UpButton.isHidden = false
        UpImage.isHidden = false
        
        //self.view.frame.origin.y = -100
        //WebView.frame.origin.y = 44
    }
    @IBAction func UpButtonAction(_ sender: Any) {
        DownButton.isHidden = false
        DownImage.isHidden = false
        MenuBar.isHidden = true
        UpButton.isHidden = true
        UpImage.isHidden = true
        
        //WebView.frame.origin.y = 20;
    }
    
    @IBAction func UpbarSurveyAction(_ sender: Any) {
        
    }
    
    @IBAction func UpbarModifyAction(_ sender: Any) {
        //let nextIndexControllerView = storyboard?.instantiateViewController(withIdentifier:"modify_controller");
        //present(nextIndexControllerView!, animated: true, completion: nil);
        performSegue(withIdentifier: "modifySegue", sender: self)
    }
    
    func powerOff(){
        let alertController = UIAlertController(title: "정말 종료 하시겠습니까?", message: "", preferredStyle : .alert);
        
        let okAction = UIAlertAction(title:"예", style: UIAlertActionStyle.default){
            UIAlertAction in exit(0);
        }
        
        let cancelAction = UIAlertAction(title:"아니오", style:UIAlertActionStyle.cancel)
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func UpbarExitAction(_ sender: Any) {
        powerOff()
    }
    @IBAction func FieldSurveyAction(_ sender: Any) {

        // 이게 본소스
        self.url = URL(string: Config.baseURL + "/app/site.html")
        self.request = URLRequest(url: self.url!)
        WebView.load(request!)

        // 이건 테스트 위한 직통
//        let nextIndexControllerView = storyboard?.instantiateViewController(withIdentifier:"fieldsurvey_controller");
//        present(nextIndexControllerView!, animated: true, completion: nil);
    }
    
    // ios x 화면 처리
//    func isiPhoneXScreen() -> Bool{
//        guard #available(iOS 11.0, *) else{
//            return false
//        }
//        return UIApplication.shared.windows[0].safeAreaInsets != UIEdgeInsets.zero
//    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return UIInterfaceOrientationMask.portrait
    }
    
    override var shouldAutorotate: Bool{
        return false
    }
    
    // Toast message function
    func toastMessage(alarm:String){
        let toastLabel = UILabel(frame: CGRect(x: view.frame.size.width/2 - 150, y: view.frame.size.height-100, width: 300, height:35))
        toastLabel.backgroundColor = UIColor.clear;
        toastLabel.textColor = UIColor.black;
        toastLabel.textAlignment = NSTextAlignment.center;
        view.addSubview(toastLabel)
        
        toastLabel.text = alarm;
        toastLabel.font = UIFont.boldSystemFont(ofSize: 12);
        toastLabel.alpha = 1.0;
        toastLabel.layer.cornerRadius = 5.0;
        toastLabel.clipsToBounds = true;
        
        UIView.animate(withDuration: 3.0, animations: {
            toastLabel.alpha = 0.0;
        }, completion: nil
            //            {
            //                (isBool) -> Void in self.dismiss(animated: true, completion: nil)
            //            }
        )
    }
    
    
    /// 새로운 세션 부분
    func syncCookies(response:URLResponse) {
        if let resp = response as? HTTPURLResponse,let headers = resp.allHeaderFields as? [String:String],let url = response.url {
            let cookies = HTTPCookie.cookies(withResponseHeaderFields:headers, for:url)
            for cookie in cookies {
                HTTPCookieStorage.shared.setCookie(cookie)
            }
        }
        syncCookiesInJS()
    }
    fileprivate func syncCookies(_ req:URLRequest) -> URLRequest {
        var request = req
        if let cookies = HTTPCookieStorage.shared.cookies {
            let dictCookies = HTTPCookie.requestHeaderFields(with: cookies)
            print(dictCookies.description)
            if let cookieStr = dictCookies["Cookie"] {
                request.addValue(cookieStr, forHTTPHeaderField: "Cookie")
                print(cookieStr)
            }
        }
        return request
    }
    
    fileprivate func syncCookiesInJS() {
        if let cookies = HTTPCookieStorage.shared.cookies {
            let script = getJSCookiesString(cookies)
            let cookieScript = WKUserScript(source: script, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            WebView.configuration.userContentController.addUserScript(cookieScript)
        }
    }
    
    fileprivate func getJSCookiesString(_ cookies: [HTTPCookie]) -> String {
        var result = ""
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss zzz"
        
        for cookie in cookies {
            result += "document.cookie='\(cookie.name)=\(cookie.value); domain=\(cookie.domain); path=\(cookie.path); "
            if let date = cookie.expiresDate {
                result += "expires=\(dateFormatter.string(from: date)); "
            }
            if (cookie.isSecure) {
                result += "secure; "
            }
            result += "'; "
        }
        return result
    }
    
    @available(iOS 9.0, *)
    fileprivate func webViewLoad(data:Data,resp:URLResponse) -> WKNavigation! {
        guard let url = resp.url else {
            return nil
        }
        let encode = resp.textEncodingName ?? "euc-kr"
        let mine = resp.mimeType ?? "text/html"
        return WebView.load(data, mimeType: mine, characterEncodingName: encode, baseURL: url)
    }
}

extension IndexController:URLSessionTaskDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        // set to manual redirect
        completionHandler(nil)
    }
    
    fileprivate func requestInCaseOf302SetCookie (_ request:URLRequest,complete:@escaping (URLRequest,HTTPURLResponse?,Data?) -> Void,failure:@escaping () -> Void ) {
        WebView.evaluateJavaScript("navigator.userAgent") {
            ua,_ in
            var req = request
            let userAgent = (ua as? String) ?? "iphone"
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
            req.addValue(userAgent, forHTTPHeaderField: "User-Agent")
            let task = session.dataTask(with: req) {
                data,response,error in
                if let _ = error {
                    failure()
                } else {
                    if let resp = response as? HTTPURLResponse {
                        /* no need for achieve Set-Cookie header because URLSession do it automatically */
                        
                        let code = resp.statusCode
                        if code == 200 {
                            // for code 200 return data to load data directly
                            complete(request,resp,data)
                        } else if code >= 300 && code <  400  {
                            // for redirect get location in header,and make a new URLRequest
                            guard let location = resp.allHeaderFields["Location"] as? String,let redirectURL = URL(string: location) else {
                                failure()
                                return
                            }
                            let request = URLRequest(url: redirectURL, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5)
                            complete(request, nil, nil)
                        }
                    }
                }
            }
            task.resume()
        }
    }
}
