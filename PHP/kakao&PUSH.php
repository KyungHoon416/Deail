<?
include "../../config/iConnect.php";


/*
TransferRoutePush 프로세스 구조
지금 구조 250627

APP PUSH(node.js 연동),카카오톡 알림톡구현

*/

$records = array(); $record = array();
$records2 = array(); $record2 = array();

$equp_gcm = array(); $user_gcm = array(); $name_gcm = array();
$equp_apn = array(); $user_apn = array(); $name_apn = array();
$equp_kko = array(); $user_kko = array(); $name_kko = array();

$ids = ""; //푸시 해당자 아이디 검색
$tType = $_POST['tType'];
$wType = $_POST['wType'];

$receiver_exp = explode("|", convert($receiver));
foreach ($receiver_exp as $val => $txt) {	
	if (!empty($txt)) {
		$exp = explode(";", $txt);
		if ($ids == "") $ids = "'" . $exp[0] . "'"; 
		else $ids .= ",'" . $exp[0] . "'"; 
	}
}

//DB 검색 USER ids 값으로 
$sql = "
	select [user] as id, name_kr, phone_ty, replace(hnum, '-', '') as phone, regist_id
	from IN_USER 
	where [user] in ($ids)
	order by name_kr";
// // echo $sql;

$rst = sqlsrv_query($conn, $sql);

while ($row = sqlsrv_fetch_array($rst)) {
	$phone_ty = trim($row['phone_ty']);
	$equip_id = trim($row['regist_id']);
	if (($phone_ty == "Android" || $phone_ty == "iOS") && !empty($equip_id)) {
		$equp_gcm[] = $equip_id;
		$user_gcm[] = $row['id'];
		$name_gcm[] = $row['name_kr'];
	}else {
		$equp_kko[] = $row['phone'];
		$user_kko[] = $row['id'];
		$name_kko[] = $row['id'].";".$row['name_kr'].";".$row['phone'];
		
	}
}


// echo "<pre>FCM equp_kko 결과 :\n";
// print_r($equp_kko);
// echo "</pre>";

// echo "<pre>FCM equip_id 체크:\n";
// print_r($equp_gcm);
// echo "</pre>";

$message = SetReplace($sMessage); //메세지 내용
$subject = SetReplace($sTitle); //메세지 제목 

// FCM 메시지 전송
$equp_cnt = sizeof($equp_gcm);

// echo "<pre>[응답 결과]\n";
// echo "FCM 결과 숫자: $equp_cnt\n";
// echo "FCM 토큰 결과 : $equip_id\n";
// echo "응답 내용: $message\n</pre>";


$rend = base64_encode(substr(strtoupper(md5(uniqid(rand()))), 0, 20)); //CDC57CBA84594DF8D2D0

$data = [
	"tokens" => $equp_gcm,  // 배열!
	"notification" => [
	  "title" => $subject,
	  "body" => $message,
	//   "image" => $imageURL, // 노출 이미지
	  "sound" => "default"
	],
	"data" => [
		"link_ty" => strval($tType), //업무유형(1공지, 2쪽지, 3감정평가, 4탁상감정, 5알림, 8문서) 
		// "link_ty" => "1", //업무유형(1공지, 2쪽지, 3감정평가, 4탁상감정, 5알림, 8문서) 
		"word_ty" => strval($wType), //문단유형(1단문, 2여러줄로)
		// "word_ty" => "2", //문단유형(1단문, 2여러줄로)
		"title" => $subject,
		"message" => $message,
		"sender" => reconv($iName),
		"rend" => $rend,
		"code" => base64_encode($code),
		// "imageURL" => $imageURL // 앱 내부 커스텀
	]
	
  ];
  
  $json = json_encode($data, JSON_UNESCAPED_UNICODE);




	// // echo "<pre> data 체크:\n";
	// // print_r($data);
	// // echo "</pre>";

	// // echo "<pre> json_encode 체크:\n";
	// // print_r($json);
	// // echo "</pre>";

  	// node.js 연동
	$ch = curl_init("http://10.38.254.15:3000/send-push"); // index.js -> app.post("/send-push" 이부분과 연동되는 페이지
	curl_setopt($ch, CURLOPT_POST, true);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($ch, CURLOPT_HTTPHEADER, [
		'Content-Type: application/json',
		'Content-Length: ' . strlen($json)
	  ]);
	curl_setopt($ch, CURLOPT_POSTFIELDS, $json);
	$response = curl_exec($ch);
	curl_close($ch);
	
	$data999 = json_decode($response);

	//  응답 로깅

/*
[응답 결과]
Array
(
    [success] => 1
    [response] => Array
        (
            [responses] => Array
                (
                    [0] => Array
                        (
                            [success] => 1
                            [messageId] => projects/daeiliosapp/messages/1750825618574416
                        )

                    [1] => Array
                        (
                            [success] => 1
                            [messageId] => projects/daeiliosapp/messages/0:1750825618583975%746962a4746962a4
                        )

                )

            [successCount] => 2
            [failureCount] => 0
        )

)
*/

/*
[success] => 1
    [successCount] => 2
    [failureCount] => 0
    [details] => Array
        (
            [0] => Array
                (
                    [success] => 1
                    [messageId] => projects/daeiliosapp/messages/1750990972535682
                )

            [1] => Array
                (
                    [success] => 1
                    [messageId] => projects/daeiliosapp/messages/0:1750990972536737%746962a4746962a4
                )

        )

*/
 	//푸시 전송 결과 내용 확인.
	// 푸시 전송 성공Count
 	$succ_cnt = $data999->successCount;
	// 푸시 전송 실패Count
 	$fail_cnt = $data999->failureCount;

	$details = $data999->details;

	//합산 = 푸시 전송 성공Count + 푸시 전송 실패Count
 	$toly_cnt = $succ_cnt + $fail_cnt;

	// 응답 로깅

	$details_ = serialize($details); 
	$data_  = serialize($data);
	$user_    = serialize($user_gcm);
	$name_    = serialize($name_gcm);

	PushMessage($details_,$data_,$user_,$name_);

function PushMessage ($details, $data, $user, $name) {
	Global $conn, $iPart, $iUser, $records2, $record2, $phone_ty, $succ_cnt, $fail_cnt, $toly_cnt, $equp_gcm;
	
	//직렬화된 변수를 받아서 배열로 변환
	$headers_ = unserialize($details);
	$fields_  = unserialize($data);
	$user_    = unserialize($user);
	$name_    = unserialize($name);

 	//푸시 전송 내용 메인 저장.
 	$dt = date('YmdHis');	
 	$link_ty = $fields_['data']['link_ty'];	
 	if ($phone_ty == "Android") {
 		$subject = convert($fields_['data']['title']);	
 		$message = convert($fields_['data']['message']);	
 	} else {
 		$subject = convert($fields_['notification']['title']);	
 		$message = convert($fields_['notification']['body']);	
 	}

 	$rend = $fields_['data']['rend'];
 	$code = base64_decode($fields_['data']['code']);
 	$fullmessage = $message;
 	$fullmessage = str_replace("&quot;", "\"", $fullmessage); 
 	$fullmessage = str_replace("&#39;", "'", $fullmessage); 
 	$fullmessage = str_replace("&amp;", "&", $fullmessage); 
 	$fullmessage = str_replace("|·", "\n·", $fullmessage); 
 	$fullmessage = nl2br(htmlspecialchars($fullmessage, ENT_QUOTES, 'ISO-8859-1'));
 	$receiver = "";
 	foreach ($name_ as $key => $val) {
 		$receiver .=  $val . "|"; 
 	}
 	$receiver = substr($receiver, 0, -1);	

 	$sql = "
 		insert into MESSAGE.DBO.SDK_GCM_SEND (multicast, branch, sender, receiver, subject, message, save_dt, toly_cnt, succ_cnt, fail_cnt, link_ty, rend, code, phone_ty)
 		values ('$rend', '$iPart', '$iUser', '$receiver', '$subject', '$message', '$dt', '$toly_cnt', '$succ_cnt', '$fail_cnt', '$link_ty', '$rend', '$code', '$phone_ty');";  
 	// // echo($sql);
 	sqlsrv_query($conn, $sql);

 	//푸시 전송 내용 상세 저장.
 	$sql = "";
 	$device_number = 0;
 


 	foreach ($headers_ as $key => $value) {
 		
 		$user_id = $user_[$device_number];
		$effect = "Failed";
    	$effectSuccess = "";
 		// NotRegistered(재설치), InvalidRegistration(재설치), MissingRegistration(설치), Unavailable(재전송)
 		if (isset($value->messageId)) {
			$effect = "Success";
			$effectSuccess = array_pop(explode('/',strtolower($value->messageId)));
			
		} elseif (isset($value->error)) {

			$effect = "Failed";
			$effectSuccess = $value->error->message ?? "UnknownError";
		}

 		$sql .= "
 			insert into MESSAGE.DBO.SDK_GCM_REPORT (multicast, no, receiver, save_dt, registrationid, result, rend)
 			values ('$rend', '$device_number', '$user_id', '$dt', '$effectSuccess', '$effect', '$rend');";  

		
 		$device_number++;
 	}
 	sqlsrv_query($conn, $sql);
 	$id = 'i' . $rend;
 	$nm = "";
 	if ($toly_cnt == 1) { $nm = $name_[0]; }
 	$full_cnt = $succ_cnt . "／" . $toly_cnt . "<br />" . $nm;	
 	$record2['permission'] = "success";
 	$record2['id'] = $id;
 	$record2['code'] = $rend;
 	$record2['schedule_ty'] = 0;	
 	$record2['transfer_ty'] = "APP";	
 	$record2['dtd'] = date("Y/m/d", strtotime($dt));
 	$record2['dts'] = date("H:i", strtotime($dt));
 	$record2['status_nm'] = reconv("완료");
 	$record2['full_cnt'] = reconv($full_cnt);
 	$record2['message'] = reconv(sText($message, 200));
 	$record2['fullmessage'] = reconv($fullmessage);
 	$record2['disabled'] = "disabled";	
 	$record2['css_'] = null;
 	array_push($records2, $record2);


	}


// 카카오톡 알림톡 전송 시작
	$equp_cnt = sizeof($equp_kko);


	if ($equp_cnt > 0) {



		$sRece    = $_REQUEST['sRece']; //발신번호
		$sTitle   = $_REQUEST['sTitle']; //제목     
		$receiver =  implode('|', $name_kko)."|"; //수신자    
		$sMessage = str_replace(array("\"", "'", "&", ""), array("", "", ""), $sMessage); 
		$sReserve = $_REQUEST['sReserve']; //예약여부
		$rYear    = $_REQUEST['rYear'];
		$rMon     = $_REQUEST['rMon'];
		$rDay     = $_REQUEST['rDay'];
		$rHour    = $_REQUEST['rHour'];
		$rMin     = $_REQUEST['rMin'];    

		$fields = array(
			'sByte'    => 'K',
			'tType'    => '1',
			'sRece'    => $sRece,
			'sTitle'   => $sTitle,
			'receiver' => $receiver,
			'sMessage' => $sMessage,
			'sReserve' => $sReserve,
			'rYear'    => $rYear,
			'rMon'     => $rMon,
			'rDay'     => $rDay,
			'rHour'    => $rHour,
			'rMin'     => $rMin
		);
		$PostData = http_build_query($fields);

	}

	$ch = curl_init();
	curl_setopt($ch, CURLOPT_URL, "http://10.38.254.13/intra/lib/kakao.1.5.1/Kakao_Sending.php");
	curl_setopt($ch, CURLOPT_POST, true);
	curl_setopt($ch, CURLOPT_POSTFIELDS, $PostData);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($ch, CURLOPT_COOKIE, "HttpDaeilUser=$iUser;HttpDaeilPart=$iPart;HttpDaeilName=$iName"); //쿠키값 추가
	//curl_setopt($ch, CURLOPT_COOKIEJAR, true); 
	$response = curl_exec($ch);
	curl_close($ch);


	$json = json_decode($response, true); 

sqlsrv_close($conn); 
?>