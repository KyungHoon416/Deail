//2025.06.12. 앱 닫기

function closeToApp(info = '') {

    const phone_ty = document.getElementById("env").dataset.menu;

    // alert(phone_ty)

    if (phone_ty === "AOS") {

        if (window.AndroidInterface) {

            window.AndroidInterface.closeApp(info);  // 앱에게 닫기 요청 전달

        }else {

            window.close();

        }

    } else if (phone_ty === "iOS") {

        webkit.messageHandlers.DaeilAppCloser.postMessage(info)

    } else {

        if (window.opener) {

            // alert("window.open 으로 열렸음!");

            window.close();

          } else {

            // alert("location.href 등으로 열린 것 같음!");

            window.history.back();

          }

        // 

    }

}


const BASE_URL = "http://220.90.216.206";



// 앱에 URL 페이지 전환

function sendUrlToApp(pageCode, idx = '', info = '') {

    const phone_ty = document.getElementById("env").dataset.menu;

    const url = getUrl(pageCode, idx, info);

    if (phone_ty === "iOS") {

        window.webkit?.messageHandlers?.openUrl?.postMessage(url);      

    } else if (phone_ty === "AOS") {

        if (window.AndroidInterface) {

            window.AndroidInterface.openUrl(url);

        }

    } else {

        window.open(url);

    }

}



function getUrl(pageCode, idx = '', info = '') {

    const routes = {

        P1: `${BASE_URL}/app/comp.html`,

        P2: `${BASE_URL}/app/shop.html`,

        P2_1: `${BASE_URL}/app/shop_view.html?${idx}`,

        P3: `${BASE_URL}/app/susu.html`,

        P4: `${BASE_URL}/app/book.html`,

        M1: `${BASE_URL}/app/1_view.html?${idx}`,

        M2: `${BASE_URL}/app/2_view.html?${idx}`,

        M3: `${BASE_URL}/app/3_view.html?${idx}`,

        M4: `${BASE_URL}/app/4_view.html?${idx}`,

        M5: `${BASE_URL}/app/5_view.html?${idx}`,

        M6: `${BASE_URL}/app/6_view.html?${idx}`,

        M6_1: `${BASE_URL}/app/6.html?${idx}`,

        M9: `${BASE_URL}/app/5_view.html?mode=save`,

        T1: `${BASE_URL}/app/poll_view.html?${idx}`,

        T2: `${BASE_URL}/app/9_view.html?${idx}`,

        T3: `camera?${idx}`,

        T4: `http://218.153.71.28/login`,

        T5: `https://m.biz.bearbetter.net/id201805`,

        T6:  `${BASE_URL}/ndab/`,

        T7:  `setting`,

        T8:  `MobileLogout`,

        D1: `${BASE_URL}/intra/appr/common/opRpptView.htm?${idx}`,

        D2: `${BASE_URL}/app/4_edit.html?${idx}`

    };

    return routes[pageCode] || `${BASE_URL}/404.html`;

}