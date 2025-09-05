//
//  AppStartController.swift
//  DaeilIosApp
//
//  Created by 대일감정원 on 2018. 2. 9..
//  Copyright © 2018년 대일감정원. All rights reserved.
//

import Foundation
import WebKit
import Alamofire
import Firebase

// 앱 처음 실행시 처음 실행되는곳인지 확인 컨트롤러
class AppStartController : UIViewController{
    
    var WebView:WKWebView?
    
    override func loadView() {
        super.loadView()
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.processPool = WKProcessPool.shared
        
        WebView?.uiDelegate = (self as! WKUIDelegate)
        WebView?.navigationDelegate = (self as! WKNavigationDelegate)
        WebView?.translatesAutoresizingMaskIntoConstraints = false
 
        let mainVer = Bundle.main.infoDictionary!["CFBundleShortVersionString"]!;
        print("현재 버젼 : \(mainVer)")
        InnerInfoDB.saveAllString(key: "version", value: mainVer as! String)
        
        ///////// 그 전버젼 시간받는게 없어서 여기에 추가 //////
        let tmpTime = InnerInfoDB.loadAllString(key: "update_time")
        if tmpTime.isEmpty{
            print("비어있다")
            InnerInfoDB.saveAllString(key: "update_time", value: getToday());
            
            // 처음에만 실행되니까 이게 처음 아이폰 버젼 체크하게 통화시켜주는 flag
            //InnerInfoDB.saveStringBool(key: "update_flag", value: true)
            //UpdateCheck();
        }
        //////// 나중에 시간받는거 지워 버려도 됨/////////////
    }
    
    // 1. 처음 실행 되는지 확인
    // 처음 실행이면 AuthController, 처음 실행이 아니면 LoginController
    // 여기 내부 DB 사용해서 확인
    
    // 2. 화면의 2초 딜레이 필요 일부러 하는거임
    
    
    // 3. 로그인 여기서 할까?
    
    override func viewDidLoad() {
        super.viewDidLoad();
        NetworkManager.shared.startMonitoring()
        // App의 자동 버젼 관리를 위해 내가 직접 해줘야하는 부분 공유 plist 파일 URL 정보 버젼마다 직접 리뉴얼 해주기

    }
    
    // 1. 항목의 처음 실행 되는지 확인 하는 부분
    // viewDidAppear : controller 에 진입시 한번만 필요한 기능 호출하는 func
    override func viewDidAppear(_ animated: Bool) {
        // 로그인 체크 여기서 할까?
        
        //var innerUserDB = InnerInfoDB.save(key: "test", value: "esg");
        //var ii = InnerInfoDB.test(key:"test");
        let firstStartCheck = InnerInfoDB.loadStringBool(key: "first");
        print("AppStartController firstStartCheck : \(firstStartCheck)");
        
        // Push가 들어오면 Push 데이터 일단 가져온다.
        
        // App이 첫 시작인지 아닌지 확인
        let storyboard = self.storyboard!
        
        // false면 첫시작
        // 약 여기서 2~3초간 Delay 필요
        if firstStartCheck == false {
            
            // AuthController 이동
            let nextAuthControllerView = storyboard.instantiateViewController(withIdentifier: "auth_controller");
            present(nextAuthControllerView, animated: false, completion: nil);
        }else{
            // 자동 로그인이 체크 되어 있으면 자동 여기서 로그인 자동 체크 해서 세션 유지
            // 자동 로그인이 체크 되어 있지 않으면 LoginController로 이동
            let autoLoginSw = InnerInfoDB.loadStringBool(key: "sw_login")
            print("AppStartController autoLoginSw")
            UpdateCheck()
            // 업데이트 확인
            //UpdateSendInfo()
//            let queue = DispatchQueue.global()
//            queue.async {
//                let mainVer = Bundle.main.infoDictionary!["CFBundleShortVersionString"]!;
//                print("현재 버젼 : \(mainVer)")
//                InnerInfoDB.saveAllString(key: "version", value: mainVer as! String)
//
//                self.UpdateCheck()
//            }

            if autoLoginSw == true {
                MobileAppLogin()
                
                //오토 로그인이 되어 있으면, 푸시데이터를 가지고 MobileAppLogin 함수로 가져간다.
                // MobileAppLogin(PUSH DATA) 이런식으로 되야할듯.
                // 아니면 별도의 임시 저장공간에 가져온 푸시 데이터 저장
                
            }else {
                if CheckFlag.modifyFlag {
                   //수정에서 자동로그인 체크해서 들어오지만 확인
                    let nextIndexControllerView = storyboard.instantiateViewController(withIdentifier:"index_controller");
                    present(nextIndexControllerView, animated: false, completion: nil);
                }else{
                    // 자동 로그인이 체크 되어 있지 않으니까 비밀번호 표시 안되게
                    InnerInfoDB.saveAllString(key: "pw", value: "")
                    print("ddddddd")
                    MobileAppLogin2()
                    
                    // LoginController 이동
                    //let nextLoginControllerView = storyboard.instantiateViewController(withIdentifier: "login_controller");
                    //present(nextLoginControllerView, animated: false, completion: nil);
                    
                }
            }
        }
    }
    
    func UpdateCheck(){
        print("UPDATE CHECK???")
        
        let intraID = InnerInfoDB.loadAllString(key: "id")
        let intraPhone = InnerInfoDB.loadAllString(key: "phone")
        
//        let userInfo : Parameters = ["ty" : "ty", "phone" : intraPhone]
        
        let urlString : String = Config.baseURL + "/intra/CheckAppVer.php?ty=2"
//        let urlString : String = "http://intra.idab.co.kr/iOSVer.php"
        print("request AppStartController UpdateCheck urlString :\(urlString)")
        AF.request(urlString, method:.post, parameters:nil).validate()
            .responseJSON{ response in
                switch response.result{
                case .success:
                    print("request AppStartController UpdateCheck response success: \(response)")
                    guard let data = response.data else { return }
                    
//                    if let usableData = response.data {
                        do {
                            let jsonArray = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)  as! [String:AnyObject]
                            //if jsonArray is [String] {// parse array here}
                            let version = jsonArray["version"]?.description
                            let shareUrl = jsonArray["route"]?.description
                            
                        
                            print("request AppStartController 읽어와라1 \(InnerInfoDB.loadAllString(key: "version"))")
                            print("request AppStartController 읽어와라2 \(version)")
                            print("request AppStartController 읽어와라3 \(shareUrl)")
//                            print(jsonArray["version"]!)
//                            print(jsonArray["route"]!)
                            ///1.version == InnerInfoDB.loadAllString(key: "version")
                            if version == InnerInfoDB.loadAllString(key: "version"){
                                print("버젼이 현재 일치")
                                let intraID = InnerInfoDB.loadAllString(key: "id")
                                let updateInfo : Parameters = ["mode":"version", "id" : intraID, "appver" : Bundle.main.infoDictionary!["CFBundleShortVersionString"]!]
                                
                                // 변경 부분
                                let updateVersion : String = Bundle.main.infoDictionary!["CFBundleShortVersionString"]! as! String
                                
                                let tsss = NSString(string: updateVersion)
                                
                                var urlUpdate : String = Config.baseURL + "/daeilasset/app_permission.php"
                                
                                if(tsss.doubleValue > 1.79){
                                    urlUpdate = Config.baseURL + "/app/MobilePermission2.php"
                                }
                                
                                print("request AppStartController UpdateCheck urlUpdate :\(urlUpdate)")
                                ////////////
                                print("request AppStartController UpdateCheck updateVersion :\(updateVersion)")
                            
                                // 여기가 원래
                                //let urlUpdate : String = Config.baseURL + "/daeilasset/app_permission.php"
                                //let urlUpdate : String = Config.baseURL + "/app/MobilePermission2.php"
                                
                                if(InnerInfoDB.loadStringBool(key: "update_flag")){
                                //if (true){
                                    AF.request(urlUpdate, method:.post, parameters:updateInfo).validate()
                                        .responseJSON{ (respones) in
                                            switch respones.result {
                                            case .success:
                                                
                                                print(respones)
                                                
                                                if let usableData = respones.data {
                                                    do {
                                                        let jsonArray = try JSONSerialization.jsonObject(with: usableData, options: .mutableContainers)  as! [String:AnyObject]
                                                        //if jsonArray is [String] {// parse array here}
                                                        let permission = jsonArray["permission"]?.description
                                                        
                                                        print(jsonArray["permission"]!)
                                                        
                                                        if permission == "1"{
                                                            print("update info set success")
                                                            InnerInfoDB.saveStringBool(key: "update_flag", value: false)
                                                        }else {
                                                            print("update info set fail")
                                                        }
                                                    } catch {print("JSON Processing Failed")}
                                                }
                                            case .failure(let error):
                                                print(error)
                                            }
                                    }
                                }
                                return
                            }else if version! <= InnerInfoDB.loadAllString(key: "version"){
                                print("지금 버전이 최신")
                                return
                            }else{
                                print("지금 버전이 낮음")
                                
                                let alertContoller = UIAlertController(title:"최신업데이트가 있습니다. 업데이트를 실행합니다.", message:"", preferredStyle: .alert)
                                InnerInfoDB.saveAllString(key: "update_time", value: self.getToday())
                                InnerInfoDB.saveStringBool(key: "update_flag", value: true)
                                let okAction = UIAlertAction(title: "확인", style:UIAlertActionStyle.default){
                                    UIAlertAction in let updateUrl = URL(string: "itms-services://?action=download-manifest&url="+shareUrl!)
                                    UIApplication.shared.open(updateUrl!, options: [:], completionHandler: {
                                        (success) in
                                        
                                    })
                                }
                                alertContoller.addAction(okAction)
                                self.present(alertContoller, animated: true, completion: nil)
                                //UIApplication.shared.delegate?.window!!.rootViewController?.present(alertContoller, animated: true, completion: nil)
                                
                            }
                        } catch {print("JSON Processing Failed")}
//                    }
                case .failure(let error):
                    print(error)
                }
               
                
                /*
                if let JSON = respones.result.value as? [String:String]{
                    let version = JSON["version"] ?? nil
                    let shareUrl = JSON["route"] ?? nil
                    print("서버 버젼 : \(version ?? nil)")
                    print("Alamofire : \(InnerInfoDB.loadAllString(key: "version"))")
                    // 메인 버젼 가져오기
                    if version == InnerInfoDB.loadAllString(key: "version"){
                        print("version Pass???")
                        return
                    }else{
                        let alertContoller = UIAlertController(title:"최신업데이트가 있습니다. 업데이트를 실행합니다.", message:"", preferredStyle: .alert)
                        
                        let okAction = UIAlertAction(title: "확인", style:UIAlertActionStyle.default){
                            UIAlertAction in let updateUrl = URL(string: "itms-services://?action=download-manifest&url="+shareUrl!)
                            UIApplication.shared.open(updateUrl!, options: [:], completionHandler: { (success) in
                                
                            })
                        }
                        alertContoller.addAction(okAction)
                        self.present(alertContoller, animated: true, completion: nil)
                    }
                }*/
        }
    }
    
    func MobileAppLogin(){
        let intraID = InnerInfoDB.loadAllString(key: "id")
        let intraPW = InnerInfoDB.loadAllString(key: "pw")
        let fcmToken = Messaging.messaging().fcmToken
        print("MobileAppLogin FCM TOKEN :  \(String(describing: fcmToken))")
        
        let userInfo :Parameters = ["mode":"login", "user_id": intraID, "user_pw": intraPW, "regt_id":fcmToken ?? "NULL"];
        let urlString : String = Config.baseURL + "/app/MobileCheck2.php";
        //let urlString : String = "http://intra.idab.co.kr/MobileCheck2.php";
        print("request AppStartController MobileAppLogin0 :\(urlString)")
        AF.request(urlString, method:.post, parameters:userInfo).validate()
            .responseJSON{ (respones) in
                
                print("request AppStartController MobileAppLogin0 respones :\(respones.result)")
                switch respones.result {
                case .success:
                    if let JSON = respones.value as? [String:String]{
                        let result = JSON["permission"] ?? nil
                        
                        if(result == "success"){
                            //print("success");
                            //쿠키에 대한 정보는 저장하는거 같은데 그게 웹뷰까지 이어지게 하는 방법이 필요
                            HTTPCookieStorage.save();
                            //인덱스 화면으로 보내줘야함
                            self.NextLoginController(flag:true);
                        }else{
                            // 로그인화면으로 보내줘야함
                            self.NextLoginController(flag: false);
                            //self.toastMessage(alarm: "사용자 정보를 다시 입력해주십시요.");
                        }
                    }
                    
                case .failure(let error):
                    print(error)
                }
            
               
        }
    }
    
    func MobileAppLogin2(){
        let intraID = InnerInfoDB.loadAllString(key: "id")
        let intraPW = ""
        let fcmToken = Messaging.messaging().fcmToken
        
        print("MobileAppLogin2 \(String(describing: fcmToken))")
        
        let userInfo :Parameters = ["mode":"login", "user_id": intraID, "user_pw": intraPW, "regt_id": fcmToken ?? "NULL"];
        let urlString : String = Config.baseURL + "/app/MobileCheck2.php";
        //let urlString : String = "http://intra.idab.co.kr/MobileCheck2.php";
        print("request AppStartController MobileAppLogin2 :\(urlString)")
        AF.request(urlString, method:.post, parameters:userInfo).validate()
            .responseJSON{ (respones) in
                
                switch(respones.result){
                case .success:
                    if let JSON = respones.value as? [String:String]{
                        let result = JSON["permission"] ?? nil
                        
                        if(result == "success"){
                            
                        }else{
                            // 로그인화면으로 보내줘야함
                            self.NextLoginController(flag: false);
                        }
                    }
                    
                case .failure(let error):
                    print(error)
                }
              
        }
    }
    
    func NextLoginController(flag:Bool){
        let storyboard2: UIStoryboard? = UIStoryboard(name: "Main", bundle: nil)
        
        if flag == true{
            
            // 인덱스 페이지
            print("APPSTART PAGE FRAG FIND LINE")
//            let nextIndexControllerView = storyboard?.instantiateViewController(withIdentifier:"index_controller")
            
            let nextIndexControllerView = storyboard2!.instantiateViewController(withIdentifier: "index_controller")
            present(nextIndexControllerView, animated: false, completion: nil)

        }else{
            // 로그인 페이지
            let nextLoginControllerView = storyboard2!.instantiateViewController(withIdentifier: "login_controller")
            present(nextLoginControllerView, animated: false, completion: nil)
        }
    }
    
    // 날짜 가져오기
    func getToday(format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let now = Date()
        let formmater = DateFormatter();
        formmater.dateFormat = format
        return formmater.string(from: now as Date);
    }
    
    func UpdateSendInfo(){
        print("UPDATESENDINFOCHECK")
        
        //if InnerInfoDB.loadStringBool(key: "update_flag")
        if true{
            
        }
    }
}
