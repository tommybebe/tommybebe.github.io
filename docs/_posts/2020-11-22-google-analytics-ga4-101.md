---
layout: post
title: Google Analytics GA4 101
subtitle: 달라진 점 + 주요 기능과 개념 + 설정 방법
keywords: GA, google, analytics, GA4
---


Google Analytics 4 속성은 베타 버전이었던 앱+웹 속성의 정식 명칭으로 2020년 10월 14일 이후 모든 새 속성의 기본 환경이자 유일한 속성이다. 대부분의 구현 환경은 유지되나 보고서 기능의 변화와 함께 데이터 수집, 보관과 관련된 새로운 기능을 활용할 수 있게 된다. 이 글에서는 새로운 속성, GA4에서 달라진 점, 주요 기능과 개념, 생성 및 설정 방법에 대해 설명한다. 

---


### 달라진 점

- 보고서
    - 메뉴 구성이 달라졌다. 보고서의 종류와 구성이 매우 달라졌다.
    - GA 360 사용자에게만 제공되었던 분석 허브가 제공된다.
- 이벤트와 사용자 속성
    - `자동으로 수집하는 이벤트`가 추가된다.
        - session_start, user_engagement, first_visit 등의 이벤트가 수집된다. 상세한 이벤트 목록은 [여기](https://support.google.com/analytics/answer/9234069)에서 확인할 수 있다.
        - 웹, 앱에 따라 자동으로 수집되는 이벤트 항목이 다르다.
        - gtag.js를 사용하면 별도의 설정없이 수집을 시작한다.
    - `향상된 측정` 기능이 제공된다.
        - [페이지 조회, 스크롤, 이탈 클릭, 사이트 검색, 동영상 시청, 파일 다운로드]가 자동으로 측정된다. 이 기능은 별도의 설정으로 켜고 끌 수도 있다.
        - 페이지 조회 이벤트는 페이지 로드 이외에도 브라우저 방문 기록 이벤트를 추적하여 기록한다. Single Page Application 등에서 pushState를 사용하여 URL을 변경하는 경우에서도 추적이 가능해진다. (이 기능 또한 해제가 가능하다.)
    - `추천 이벤트` 기능이 제공된다.
        - 이벤트 이름과 파라미터 이름에 선점된 키워드가 존재하고, 그에 맞춰 이벤트 로그를 남길 경우 그에 맞춰 특별히 제작된 보고서를 볼 수 있게 된다.
    - `Event Name + Parameters` 로 이벤트를 전달하게 되었다.

        ```js
        // As-is 
        ga('send', 'event', [eventCategory], [eventAction], [eventLabel], [eventValue]);

        // To-be
        gtag('event', 'login', {'key1': 'value1', 'key2': 'value2'});
        ```

        - Firebase의 그것과 동일한 구성으로 변경된 셈이다. 기존의 [Category, Action, Label, Value]과 같이 배열 객체가 아니라 이벤트의 이름과 파라미터 오브젝트로 구성하여 이벤트를 기록한다.
        - 입력 파라미터의 제한 또한 Firebase의 그것과 동일하다.
            - 고유 이벤트 이름 500개, 이벤트당 파라미터의 수 25개, 파라미터 이름 길이 40글자, 파라미터 값 길이 100글자 (영문 기준인 점을 주의해야 한다.)
    - `사용자 속성` 이 추가되었다.
        - 이벤트와 마찬가지로 사용자 속성 또한 Firebase와 동일한 제한을 가진다.
            - 속성 당 사용자 속성 25개, 이름의 길이 24글자, 값의 길이 36글자
        - 기존의 Custom dimension을 대체하는 개념이다.
- 개선된 데이터 제어
    - 데이터 수집 기능이 개선되었다.
        - 구글 신호 데이터 (교차 기기 잠재고객) 수집 설정, 광고 개인 최적화 지역 제어, 사용자 데이터 수집 확인 등을 설정할 수 있다.
    - 데이터 보관
        - 집계 데이터가 아닌 사용자 수준의 데이터의 보관 기간을 설정할 수 있다. [2개월, 14개월] 중 선택할 수 있다.
    - 데이터 필터
        - 뷰 단위가 아닌 속성 단위에서 데이터 필터를 적용하도록 변경되었다.
        - 개발자 트래픽 혹은 내부 트래픽으로 구분하여 필터링 할 수 있다.
        - 데이터를 제거하거나, 식별자를 추가 할 수 있다.

### 주요 기능과 개념

- 속성

    The level of the Analytics account that determines which data is organized and stored together.

    - 속성은 다수 스트림을 가질 수 있다. 따라서 다수 앱이나 다수 웹페이지의 기록을 수집하고 저장할 수 있다.
    - 스트림 설정과 앱/웹과의 연결 없이는 아무런 데이터도 수집되지 않는다.
- 데이터 스트림

    The flow of data from an app or website to your Google Analytics 4 property.

    - 데이터 스트림을 통해 앱, 웹 등과 직접적으로 연결하여 정보를 수집하게 된다.
    - 웹사이트에 설치한 gtag 혹은 태그매니저가 스트림에 데이터를 전달하게 된다.
    - 각 스트림마다 태그 설정이 가능하다. (이벤트의 수정이나 추가, 내부 트래픽의 정의)
    - iOS, Android, Web 스트림 연결 제공
    - 각 스트림마다 측정 프로토콜 API 비밀번호 관리가 가능하다.
        - POST Request를 통해 이벤트를 기록할 수 있다. 이 때 API 비밀번호를 사용한다.
- gtag.js
    - 로그 수집을 위한 자바스크립트 라이브러리. 수집 대상 웹페이지에 항상 삽입되어야 한다.
    - 코드 스니펫이 실행되는 즉시 페이지 조회 등의 [자동 수집 이벤트 기록](https://support.google.com/analytics/answer/9234069)이 남기 시작한다.
        - React 등을 사용하는 SPA에서 pushState 등의 URL change event 없이는 인식되지 않고, 페이지 조회 기록이 누락된다.
- 이벤트

    Data that represents a user interaction that your site or app sends to Google Analytics.

    - 가장 작은 단위의 기록이다.
    - gtag 코드를 삽입하여 실행한다.

        ```js
        gtag('event', 'login', {'key1': 'value1', 'key2': 'value2'});
        ```

- 사용자 속성

    An attribute of a user, such as age, gender, language, and country.

    - 사용자 수준의 기록이다.
    - 이벤트의 발생과 무관하게 기록 이후의 모든 레코드에 고정된다. (새로운 값으로 업데이트하기 전까지)

### 필수 설정

1. 계정과 속성 생성
    - 가장 먼저 Google Analytics 계정 생성부터 진행한다.
        ![medium](/assets/2020/ga-create-account-1.png) *계정이 없는 경우 첫 페이지*
        ![medium](/assets/2020/ga-create-account-2.png) *계정 이름 설정*
    - 속성을 생성한다.
        ![medium](/assets/2020/ga-create-property.png) 
2. 스트림 생성
    - 속성에 연결할 스트림을 생성한다.
        ![medium](/assets/2020/ga-stream-add.png)
    - 스트림의 URL, 이름을 지정한 뒤 생성을 완료한다. 
3. 태그 추가
    - 생성한 스트림에 스크립트 삽입을 위한 코드 스니펫이 제공된다. 해당 코드를 웹사이트의 해더에 삽입한다.

        ```html
        <!-- Global site tag (gtag.js) - Google Analytics -->
        <script async src="https://www.googletagmanager.com/gtag/js?id=G-0000000000"></script>
        <script>
          window.dataLayer = window.dataLayer || [];
          function gtag(){dataLayer.push(arguments);}
          gtag('js', new Date());
          gtag('config', 'G-0000000000');
        </script>
        ```

        - 실제로 이 스크립트는 태그매니저의 그것과 거의 동일하다. 새로운 스크립트만으로도 태그매니저 미리보기 기능에 적용되어 이벤트 디버깅이 가능하다.
        - 내부 구현은 analytic.js를 사용한다. gtag는 analytic 제품과 함께 구글의 다른 제품들 - tagmanger, Ads 등의 wrapper library이다. 이러한 제품들과 연동하지 않는다면 gtag.js의 60kb를 로드하는 데에 더 많은 시간과 자원을 사용하게 되는 셈이다.
4. 테스트
    스크립트 삽입 이후에 태깅이 잘 설정되었는지 확인하는 방법(디버깅 방법)이 다수 지원된다.
    필수적으로는 웹사이트 헤더에 스크립트 삽입이 정상적으로 되었는지 확인하는 것이 필요하고 이후 개발자 도구에서 상세한 설정값들과 이벤트 발생 기록 등을 확인할 수 있고, 디버그뷰 보고서를 통해 실제 Google Analytics 제품에 정보가 전달되는지와 어떤 정보가 전달되었는지 검수할 수 있다. 
    1. 스크립트 실행 확인
        - 배포 이후 브라우저에서 웹페이지로 이동하여 스크립트가 정상적으로 삽입되었는지 확인한다.
        - 웹 사이트에 스크립트 삽입을 확인한다. 크롬 브라우저 → 검사 → html 영역에서 삽입된 스크립트가 헤더 영역에 있는지 확인한다.
            ![medium](/assets/2020/ga-script-added.png)
    2. 콘솔 출력 확인
        - [디버그 도구](https://chrome.google.com/webstore/detail/google-analytics-debugger/jnkmfdileelhofjcijamephohjechhna)를 설치한다.
        - 디버그 모드를 활성화한다. (클릭하면 On/Off 토글된다.)
            ![small](/assets/2020/ga-extention.png)
        - 활성화 이후 콘솔을 확인하면 GA에 전달되고 있는 모든 정보들을 확인할 수 있다.
            ![medium](/assets/2020/ga-extention-activated.png)
    3. 디버그뷰 보고서 확인
        - 메뉴 → DebigView 메뉴로 이동한다. 현재 디버그 모드가 활성화된 기기의 이벤트 스트림을 확인할 수 있다.
            ![medium](/assets/2020/ga-debugview.png)
        - 각 파라미터를 선택하여 실제 입력한 매개변수의 값을 확인할 수 있다. 
    4. 실시간 보고서 확인
        - 메뉴 → 실시간 메뉴로 이동한다. 실시간 개요 페이지에서 현재 접속 중인 사용자 전체를 확인할 수 있다.
            ![medium](/assets/2020/ga-live.png)

    

### 부가 설정

- 빅쿼리 연동

    빅쿼리와 연동 시 원본 데이터에 직접 접근이 가능해진다. 즉, Google Analytics의 보고서뿐만 아니라 다른 BI 도구나 분석용 도구들 - jupyter, datastudio, tableau 등으로 데이터를 옮겨 활용하는 것이 가능해진다. 

    - 속성별 차이
        - Firebase와 연동한 속성, 일반 혹은 신규 속성의 경우 설정 가능한 메뉴가 상이하다.
        - Firebase에서 속성 생성한 경우 GA 관리 도구에서 빅쿼리 연동하는 대신, Firebase console → settings → integration 에서 설정한다. (Exported Integration 항목에 GA와 거의 동일한 설정이 있다.
        - 그 외의 경우 GA → 관리 → BigQuery 연결에서 설정한다.
    - 설정 순서 및 항목
        1. GA Property 관리 페이지로 이동 → BigQuery 연결 선택
        2. BigQuery 프로젝트와 지역 설정 
            - 데이터세트의 이름까지 지정할 수 없다. Google의 naming rule에 따라 자동 생성된다.
        3. 스트림 설정
            - 앞서 설정해둔 스트림 중 빅쿼리 연동할 스트림을 선택해야 한다.
        4. 광고 식별자 포함 여부 
            - 광고 식별자 - ADID, IDFA, IDFV에 대한 기록 여부를 설정한다.
        5. 빈도 설정
            - 매일 : 매일 한번씩 새로운 테이블을 생성한다. 필수적으로 선택되어야 한다.
            - 스트리밍 : 실시간 내보내기 기능이 활성화 된다. 스트리밍 입력의 비용이 별도로 부과되므로 주의가 필요하다. ([Bigquery streaming insert pricing](https://cloud.google.com/bigquery/pricing)을 따른다.)
    - 주의사항
        - 속성당 하나의 프로젝트에만 연결이 가능하다.
        - 2020-12-07 이후 Realtime Streaming Insert 설정이 기본 활성화된다. [빅쿼리의 가격정책](https://cloud.google.com/bigquery/pricing)을 따라 과금된다. (전달할 이벤트 파라미터의 길이와 무관하게 하나의 레코드가 1kb의 최소 사이즈를 가지는 것에 주의해야 한다. 즉, 파라미터가 비어있는 이벤트를 보낸다 해도 하나의 이벤트당 1kb로 계산된다.)
        - Firebase Project와 연동된 속성이라면, Firebase project의 요금제 설정이 종량제여야 한다. 무료 요금제를 사용중이라면 빅쿼리 연동을 설정할 수 없다.
        - 즉시 데이터 입력이 진행되지 않는다. 하루 정도 기다려야 한다.

            연결이 완료되면 24시간 이내에 데이터가 BigQuery 프로젝트로 전송되기 시작합니다. 일일 내보내기를 사용 설정하면 전날의 데이터가 포함된 1개의 파일(일반적으로 보고서에 설정한 시간대의 이른 오후)이 매일 내보내기됩니다.

- 데이터 필터

    내부 트래픽 혹은 테스트 과정에서 입력된 데이터를 식별할 수 있도록 식별자를 추가하거나 기록에서 제외시킬 수 있다. 

    - 설정 순서 및 항목
        - 내부 트래픽 설정

            속성 수준에서 설정된 IP를 기준으로 내부 트래픽을 구분한다. 따라서 설정해둔 스트림보다 상위 수준에서 설정하고, 적용된다. 

            1. GA Property 관리 페이지로 이동 → Data Stream 선택
            2. Additional Settings → More Tagging settings 선택 
            3. Define internal traffic → Create 클릭, 설정 입력 후 생성
                - traffic_type : 내부 트래픽을 제외하지 않고 테스트로 설정하는 경우, 매개변수 키 이름이다. 입력한 문자열이 매개변수의 값으로 입력된다.
                - IP주소 : IP 주소를 기준으로 필터링 설정한다. IP 일치/시작/끝/포함/범위 조건 설정이 가능하다.
        - Data Filter 설정
            1. GA Property 관리 페이지로 이동 → Data Settings → Data Filters 선택
            2. Create Filter 클릭 → 용도에 따라 [Developer Traffic, Internal Traffic] 선택
            3. 설정 입력 후 생성
                - 필터 연산 : 필터 조건에 해당하는 경우 제외하거나 포함시킬 수 있다.
                - traffic_type : 필터 상태를 테스트로 설정하는 경우 추가될 식별자의 값을 설정한다.
                - 필터 상태 : 테스트로 설정하는 경우 별도의 식별자를 붙이게 되고, 활성으로 설정하는 경우 기록에서 제외된다.
    - 주의사항
        - 설정한 필터 상태가 활성으로 설정되는 경우, 데이터가 기록에서 제외된다. 어디에도 데이터가 보관되지 않게 된다.
        - 필터 적용 이후부터 적용 된다. 소급 적용되지 않는다.


### References

- 공식 가이드
    - [유니버설 애널리틱스와 Google 애널리틱스 4 데이터 비교](https://support.google.com/analytics/answer/9964640)
    - [차세대 Google Analytics 소개](https://support.google.com/analytics/answer/10089681)
    - [Google 애널리틱스 4 속성에 대한 BigQuery Export](https://support.google.com/analytics/answer/9358801)
    - [데이터 보관](https://support.google.com/analytics/answer/7667196)
    - [데이터 필터](https://support.google.com/analytics/answer/10108813)
    - [GA4 이벤트](https://support.google.com/analytics/answer/9322688), [자동으로 수집되는 이벤트](https://support.google.com/analytics/answer/9234069),  [수집 및 구성 한도](https://support.google.com/analytics/answer/9267744)
    - [Measurement Protocol (Google Analytics 4)](https://developers.google.com/analytics/devguides/collection/protocol/ga4)
    - [BigQuery Export 설정](https://support.google.com/analytics/answer/9823238)
- 소개 글
    - [Introducing the new Google Analytics](https://blog.google/products/marketingplatform/analytics/new_google_analytics/)
    - [Meet Google Analytics 4: Google’s vision for the future of analytics](https://searchengineland.com/google-analytics-4-adds-new-integrations-with-ads-ai-powered-insights-and-predictions-342048)
    - [How To Exclude URL Query Parameters in Google Analytics](https://www.bounteous.com/insights/2020/05/15/excluding-url-query-parameters-google-analytics/)
    - [Google Analytics 4 — What, Why, and How](https://theanilbatra.medium.com/google-analytics-4-what-why-and-how-f5ee198abb76)
- Tools
    - [Google Analytics Debugger](https://chrome.google.com/webstore/detail/google-analytics-debugger/jnkmfdileelhofjcijamephohjechhna)