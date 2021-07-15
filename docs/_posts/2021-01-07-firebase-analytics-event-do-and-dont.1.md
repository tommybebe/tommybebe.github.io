---
layout: post
title: Firebase Analytics, Do and Don't
subtitle: 기록 잘 남겨서 잘 보는 방법
keywords: Firebase, BigQuery, log, event
published: false
---



클라이언트 영역 - 앱이나 웹으로 구현된 제품에서는 로그를 남겨 이러한 기록을 확인하게 되고 Firebase, Google Analytics, Amplitude 등이 사용된다. 이 글에서는 Firebase 사용을 예시로 기록을 남기는 방법에 대한 방법에 대해 안내하고 잘못된 기록과 적절한 기록의 예시를 나열해 비교하려고 한다. 

특정한 제품에 한정하여 데이터를 확인하는 것보다는 범용적인 사례들을 출력하기 위해 Firebase Analytics의 보고서 기능 대신 BigQuery에서 데이터를 직접 확인하고 추출하기 위해서 firebase-public-project에서 제공하는 공개 데이터 세트를 사용할 것이다. 

---

### Firebase의 이벤트 로그 형태

Firebase의 이벤트는 이벤트 이름과 이벤트 파라미터, 두 개의 컬럼으로 구성된다. 파라미터는 배열 형태로 배열 안에 복잡한 구조를 가질 수 있다. 이벤트를 대표하는 것은 이벤트의 이름이고, 이벤트를 설명하는 것은 파라미터, 파라미터를 설명하기 위한 정보들은 key, 실제 설명은 value에 입력하는 식이다. 간략히 표현하자면 아래와 같다. 

<iframe style="border:none" width="100%" height="450" src="https://whimsical.com/embed/523a7KjSJ28Zy3pwQ2diZw"></iframe>

- 입력 값
    - event_name : 이벤트의 이름. 사용자 행동이나 앱의 기능 실행 등, 동작과 관련된 이름을 붙이는 것이 일반적이다.
    - event_params : 이벤트 이름과 함께 붙여넣을 파라미터의 상세 정보. key-value 쌍의 배열을 가진다.
        - key : 이벤트 파라미터의 이름.
        - value  : 이벤트 파라미터의 값.
            - value는 값에 따라서 다시 [int, float, double, string] 분리되어 저장된다.
            - 개발 시 type을 지정하여 입력하는 것이 아니기 때문에 특정 type 입력을 일관되게 유지하기 위해서는 입력 전에 값에 대한 casting이 필요하다.
- 제한
    - 모든 입력 값에 제한이 있으며 입력 값에 따라서 다른 제한을 가진다. 이벤트 이름의 종류와 파라미터 개수 등의 제한과 함께 입력 값의 글자 수도 제한이 존재한다.
    - 이벤트 이름의 종류는 500가지, 이벤트 이름은 40글자, 이벤트 파라미터의 개수는 25개, 이벤트 파라미터 키는 40글자, 값은 100글자이고 영문을 기준으로 하므로 한글을 입력하는 경우 길이에 주의해야 한다.
    - 제한에 대한 정책 변경은 자주 있는 일이 아니었으나, 이 또한 업데이트가 되었다. 따라서 이 제한에 대해 필요할 때마다 공식 문서 - [Collection and configuration limits](https://support.google.com/firebase/answer/9237506?hl=en) - 를 확인하길 권장한다.

### 자동으로 남는 이벤트

Firebase Analytics 초기 설정을 끝내면 자동적으로 이벤트가 수집되기 시작한다. 앱 설치/제거/업데이트 등의 이벤트부터 광고 노출/클릭이나 딥 링크 유입 등의 채널/경로 확인을 위한 이벤트, 첫 방문이나 세션 시작 등의 사용자 행동과 관련된 이벤트 등이 제공된다. Firebase Analytics의 버전 업데이트에 따라 많은 이벤트와 파라미터가 추가되었다. 앞으로도 그럴 듯하다. 

자동으로 남는 이벤트들의 파라미터들은 모두 Firebase가 지정한 형식이고 각각의 파라미터 키에 대한 설명이 매우 부실하다. 이름으로 그 용도를 유추하거나 Stack Overflow 등의 커뮤니티를 찾아보아야 한다. 혹은 분석에 활용이 불가능한, 그야말로 Firebase 자체적인 운영을 위한 정보들이 삽입되어 있다. (`firebase_` 로 시작하는 파라미터 키 들이 보통 그러하다.)

- 예시 이벤트
    1. screen_view event
        - 발생 조건 : 이전에 설정된 스크린이 없을 때, 새 스크린이 이전 스크린과 [name, class name, id]가 다를 때 발생한다. 스크린은 iOS의 경우 UIViewController, Android의 경우 Activity를 의미한다. 즉, 그 이하 컴포넌트의 변화(fragment 등의)는 screen_view를 발생시키지 않는다. (별도로 manualy logging을 위한 방법이 제공된다.)
        - 파라미터
            - firebase_conversion : conversion으로 설정한 이벤트 유무
            - firebase_screen_class : 스크린의 class name
            - firebase_screen_id : 스크린의 아이디
            - firebase_previous_class : 이전 조회된 스크린의 class name
            - firebase_previous_id
            - engagement_time_msec
        - 저장된 데이터 예시

            ![https://s3-us-west-2.amazonaws.com/secure.notion-static.com/a20455a7-ed04-4b65-b44e-ee178e4f6f2d/__2021-01-07_223722.jpg](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/a20455a7-ed04-4b65-b44e-ee178e4f6f2d/__2021-01-07_223722.jpg)

- user_engagement event
    - 발생 조건 : 앱이 foreground에 있을 때 일정 시간마다 발생한다.
    - 파라미터
        - ga_session_id : Google Analytics 세션 아이디, 사용자 고유 식별자로 사용될 수 없다.
        - ga_session_number : ga_session_id 세션의 세션 순서 번호
        - firebase_screen_id : 조회 중인 스크린의 아이디 (Firebase 자체 사용되는 식별자)
        - firebase_event_origin : 이벤트의 소스
        - firebase_screen_class : 스크린 클래스,
        - engaged_session_event
        - engagement_time_msec
    - 저장된 데이터 예시

        ![https://s3-us-west-2.amazonaws.com/secure.notion-static.com/09b89bf6-857f-49c3-8afc-6fa4c05e0f85/__2021-01-07_223853.jpg](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/09b89bf6-857f-49c3-8afc-6fa4c05e0f85/__2021-01-07_223853.jpg)

- 주의사항
    - 위 2018년의 예시 그림에서는 없는 파라미터들이 현재는 추가되어 기록되는 경우가 있다. 앞으로도 파라미터가 추가될 가능성이 있을 것이고 그에 대한 설명을 잘 찾아보기 힘들거나 부족한 부분이 많다.
    - 활용할 수 없는 정보(firebase_screen_id 같은 경우)가 많다. 의도와 다르게 동작하는 경우도 있다.
    - 번역이 꽤 늦게 되기 때문에 가이드 혹은 안내글을 볼 때는 꼭 영어로 문서를 확인해야 한다.

### Firebase Analytics - Custom Events

자동으로 남는 이벤트와 유사하게 Custom Event를 기록할 수 있다. 기록 형식이나 파라미터의 형태 등의 Firebase 자체의 제한을 제외하면 사용 방법에 제한이 크지 않다. 원하는대로 기록하고 볼 수 있게 된다. 

- 저장된 데이터 예시

    ![https://s3-us-west-2.amazonaws.com/secure.notion-static.com/f6b851cd-306f-48e4-91b7-018471c70c96/__2021-01-07_230548.jpg](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/f6b851cd-306f-48e4-91b7-018471c70c96/__2021-01-07_230548.jpg)

    이벤트의 이름과 key가 다른 점을 제외하면 형태는 자동으로 수집된 이벤트와 완전히 동일하다. 

### Firebase Analytics - 사용자속성, 앱/디바이스 정보

이벤트만으로 정보를 구성하는 것 외에도 사용자 수준의 기록 혹은 디바이스 정보와 같이 항상 이벤트와 기록을 같이 남겨두면 좋을 정보들이 있다. 앱 버전이나 아이디, 디바이스 이름, 접속 지역 등의 정보는 Firebase가 자동으로 수집을 하고, 그 외의 별도 정보를 추가하고 싶다면 사용자 속성을 사용하면 된다. 

사용자 속성은 이벤트와 매우 유사한 형태이지만, 이벤트와 달리 일회성의 기록이 아니라 기록 이후의 모든 이벤트 옆에 함께 기록된다. 

<iframe style="border:none" width="100%" height="450" src="https://whimsical.com/embed/AurvEFCpQHzN7DEyw5jjFa"></iframe>

- 주의사항
    - 이벤트와 다른 개수/글자수 제한을 가진다. 사용할 수 있는 속성이 25개로 제한되며 24글자 키 / 36글자 값 글자수 제한이다. 이벤트보다 더 엄격한 제한이다.

### 정책 제작

자동으로 수집되는 이벤트를 제외하고, Custom Event 혹은 User Properties의 기록을 위해서는 이벤트의 이름이나 파라미터의 이름, 값들을 정해주는 과정이 선행되어야 한다. 누가 그것을 정하느냐와는 이슈와는 별개로, 이 작업이 원활하게 선행되느냐 아니냐에 따라 원하는 정보를 볼 수 있느냐 없느냐가 결정된다.

성과를 측정할 필요가 없는 이슈에서부터 개선된 지표를 확인하는 것이 목적인 이슈까지 사안에 따라서 이러한 정책 제작의 중요도는 매우 달라지게 된다.

- Guideline
    - Firebase 제한을 피한다.
        - 25개 파라미터 제한, 100글자 값 길이 제한을 고려해야 한다. 파라미터 개수의 제한 때문에 앱에서 보유하고 있는 모든 상태값을 넣을 수도 없고 글자 길이 때문에 긴 URL을 삽입할 수 없다. 단순히 제한을 넘는 파라미터나 값을 지운채 이벤트를 발생시키는 식으로 해결하려 한다면 가장 중요한 정보가 잘려나간채 기록되는 불운한 상황을 피할 수 없게 된다.
        - 즉, 보유한 모든 정보를 기록으로 남길 수 없고 필연적으로 기록할 주요한 정보가 무엇인지 선택하고 정제해야 한다.
        - 예시

            ```json
            // Don't
            { 
              "event_name": "click",
              "event_params": {
            		"url": "https://google.com/path/to?param1=value1&param2=value2...param100=value100",
              }
            }

            // Do
            { 
              "event_name": "click",
              "event_params": {
            		"param1": "value1",
            		"param50": "value50"
              }
            }
            ```

    - 조회 시 편의를 고려한다.
        - 이벤트를 기록하는 상황에 따라 필요한 정보가 매우 다를 것이므로, 이벤트에 따라 파라미터에 넣을 정보가 매우 달라질 것이다. 또한, 파라미터는 key, value 쌍으로 쌓여 저장되므로 이벤트마다 키가 달라도 저장과 조회에는 문제가 없다.
        - 특정 파라미터 키의 값을 조건으로 하는 경우 보통은 아래와 같은 SQL을 작성한다.

            ```sql
            -- example 1.
            SELECT
              count(distinct user_pseudo_id) user_count
            FROM 
              `firebase-public-project.analytics_153293282.events_*`,
              unnest(event_params) e
            WHERE
              event_name = 'level_complete_quickplay'
              and e.key = 'board'
              and e.value.string_value = 'S'

            -- example 2.
            SELECT
              count(distinct user_pseudo_id) user_count
            FROM 
              `firebase-public-project.analytics_153293282.events_*`
            WHERE
              event_name = 'level_complete_quickplay'
              and (select value.string_value from unnest(event_params) where key='board') = 'S'
            ```

        - 위와 같이 파라미터들(event_params)이 담긴 컬럼을 풀어헤쳐 값을 찾아야 하는 과정이 필요하게 된다. 따라서,
            - 조회 시마다 특정 파라미터를 골라 읽는 것이 아닌 event_params 컬럼 전체를 매번 조회해야 하므로 조회 비용이 증가한다.
            - 부풀려진 레코드 수에 정렬을 할 경우 (window function을 사용하는 등) 빅쿼리의 메모리 초과 에러를 만나게 되기 쉽다.
        - 원본 데이터를 직접 다룰 데이터 엔지니어를 제외한 사용자들 입장에서는 각 파라미터 키를 컬럼으로 가지는 테이블이 제공되는 것이 훨씬 작업에 수월할 것이다. 이 경우 선택할 수 있는 평범한 옵션은,
            1. 하나의 테이블에 모든 이벤트를 적재한다. → 파라미터 키의 종류를 줄인다. 모든 이벤트의 파라미터를 공용으로 사용할 수 있는 이름으로 만들어 사용한다.
            2. 이벤트마다 테이블로 분리한다. → 이벤트마다 다른 파라미터를 가질 수 있게 하되 스키마를 각각 별도로 관리한다. 
        - 예시

            ```json
            // Don't
            { 
              "event_name": "level_complete_quickplay",
              "event_params": {
            		"completed_level": 10
              }
            },
            { 
              "event_name": "level_start_quickplay",
              "event_params": {
            		"started_level": 10
              }
            }

            // Do
            { 
              "event_name": "level_complete_quickplay",
              "event_params": {
            		"value": 10
              }
            },
            { 
              "event_name": "level_start_quickplay",
              "event_params": {
            		"value": 10
              }
            }
            ```

    - 구분 가능한 식별자를 남긴다.
        - 공통 규격의 버튼이나 스낵바 등에 대한 기록을 남겨야 할 때, 어떤 상황인지에 대한 정보가 없다면 기록 확인이 매우 어려워진다. 어느 화면에서 발생하는지 혹은 어떤 메시지를 가졌는지 등, 노출된 엘리먼트가 어떤 상황인지 인지할 수 있을만큼 충분한 식별자를 추가해주어야 한다.
        - 예시

            ```json
            // Don't
            { 
              "event_name": "click",
              "event_params": {
                "component_name": "button",
              }
            }

            // Do
            { 
              "event_name": "click",
              "event_params": {
                "component_name": "button",
                "text": "Go",
            		"screen_name": "game_board"
              }
            }

            // Do Better
            { 
              "event_name": "click",
              "event_params": {
                "component_name": "button",
                "component_type": "primary",
                "component_state": "disabled",
                "text": "Go",
            		"screen_name": "game_board"
              }
            }
            ```

    - 일관된 데이터 타입을 유지한다.
        - 파라미터의 값은 네 가지 타입(string, int, float, double)을 가질 수 있다. 타입을 미리 선언하고 입력하는 것이 아니라 입력한 값에 따라 Firebase/BigQuery가 자동적으로 타입을 인식하고 저장한다.
        - 문제는 입력 값이 어플리케이션의 버전 업데이트 등에 의해 변경되는 경우, 해당 시점 전/후에 따라 스키마가 변경될 수 있다는 점이다. 이벤트 데이터의 구조상 타입에 따라 4개의 컬럼에 맞춰 저장되고 4개 컬럼 중 3개 컬럼은 빈 채로 남게 된다. SQL 조회 시 특정 컬럼을 선택하게 되는데 매번 달라진다면 달라질 때마다 SQL을 변경해야 하므로 매우 번거롭게 된다.
        - 예를 들어

            ```sql
            -- example 1.
            SELECT
              count(distinct user_pseudo_id) user_count
            FROM 
              `firebase-public-project.analytics_153293282.events_*`,
              unnest(event_params) e
            WHERE
              event_name = 'level_complete_quickplay'
              and e.key = 'value'
              and e.value.int_value = 10
            ```

    - 사용자 행동과 기능 실행을 구분한다.
        - 사용자 행동에 의해 실행된 기능의 기록을 남긴다 할 때, 예를 들어 `00 페이지에서 xx 버튼을 눌러서 ## 생성할 때` 할 때 `xx 버튼 클릭`은 사용자 행동 `## 생성`은 기능 실행이다. 어느 시점에 기록을 남기느냐에 따라 추후 정보로 가공하는 과정이 매우 달라진다.
        - 결과를 확인한 뒤 `클릭 + 결과` 하나의 이벤트로 묶어 기록하거나 `클릭`과 `결과`, 두 개의 이벤트로 나눠 기록할 수 있을 것이다. `xx 버튼 클릭`의 결과로 `## 생성`, `## 생성 실패` , `## 생성 기능 오류` 등이 발생할 수 있는 경우 모두 고려되어야 한다.
        - 예시

            ```sql
            // Don't
            { 
              "event_name": "click",
              "event_params": {
                "component_name": "button",
                "text": "Go",
                "result_of_click": "function_execution_fail"
              }
            }

            // Do
            { 
              "event_name": "click",
              "event_params": {
                "component_name": "button",
                "text": "Go",
              }
            },
            { 
              "event_name": "result_of_click",
              "event_params": {
                "result": "fail",
              }
            }
            ```

    - 기록 시점에 대해 정의한다.
        - 기록 시점에 따라 가진 정보가 다르다.
            - 기능 실행 시작 시점에서는 기능의 실행이 시작되었음을 알 수 있으나 결과에 대해 알 수 없다.
            - 기능 실행 종료 시점에서는 결과를 알 수 있으나 실행 중 이탈이나 오류에 대해 알 수 없다. 또한 시작 시점에 가지고 있던 정보를 종료 시점까지 기록을 위해 보관해두어야 한다.
        - 실행과 종료가 동시에 일어나는 기능이라면 실행과 종료를 구분하는 것이 차이가 없을 수 있다. 하지만 이러한 경우는 정말 드물고 구분하여 확인할 필요가 없을만큼 사소한 경우는 많을 것이다.
    - 불필요한 반복을 피한다.
        - 이미 이벤트 이름이나 다른 파라미터로 충분히 알 수 있는 정보를 굳이 반복하여 기록할 필요가 없다. 각 값의 조합으로 조회가 가능하다는 점을 감안하여 이름을 지어주는 것이 `미관상` 좋다.
        - 예시
            ```json
            // Don't
            { 
              "event_name": "level_complete_quickplay",
              "event_params": {
            		"level_complete_quickplay_value": 10,
                "level_complete_quickplay_board": "S"
              }
            }

            // Do
            { 
              "event_name": "level_complete_quickplay",
              "event_params": {
            		"value": 10,
                "board": "S"
              }
            }

            // or 
            { 
              "event_name": "quickplay",
              "event_params": {
                "type": "level_complete",
            		"value": 10,
                "board": "S"
              }
            }
            ```

### 기록 확인

Firebase Event를 BigQuery에서 데이터를 확인하려면 [BigQuery 연동](https://support.google.com/firebase/answer/6318765?hl=en)을 설정해두어야 한다. 연동이 잘 완료되면 dataset의 이름을 볼 수 있게 된다. 이때부터 Firebase Analytics 데이터가 BigQuery에 전달되기 시작한다. 

- 데이터 저장 과정

    <iframe style="border:none" width="100%" height="450" src="https://whimsical.com/embed/JLSSwHHjBxeBhVPFAo1WyN"></iframe>

    1. Firebase 가 `events_intraday_yyyymmdd` 형식의 테이블을 생성한 뒤 실시간 데이터를 Streaming Insert한다. 
    2. 다음날이 될 때 Streaming Insert를 중단하고 `events_yyyymmdd` 테이블에 복사한다.
        - 다음날이 될 때에도 마찬가지로 해당일자에 해당하는 이름의 새로운 테이블이 생성된다.
        - 사본 생성이 완료되면 어제자 `events_intraday_yyyymmdd` 테이블은 삭제된다.
    - 주의점
        - 테이블의 이름은 `events_` prefix 뒤에 yyyymmdd 형식(ex: 2021년 1월 1일인 경우 20210101)의 suffix를 붙여 생성된다.
        - 즉, 위 설명에서 `yyyymmdd`는 실제로는 `20010101` 같은 형식이 된다.
- 데이터 확인 방법
    - 다수 테이블 한번에 조회하기
        - 데이터 저장 과정에서 설명했듯, 일자별로 생성된 테이블이 다수 존재하게 되므로 일반적인 방법으로 조회하기 번거롭다.
        - BigQuery는 다수 테이블을 저장된 테이블을 한번에 읽을 수 있도록 wildcard를 사용한 테이블 조회를 지원한다.
            - `analytics_100000.events_*` 라고 쓰면 모든 일자의 데이터를 조회하게 된다.
            - wildcard를 사용하는 경우 해당하는 영역의 문자열을 값으로 가지는 `_table_suffix` 라는 특수한 컬럼을 사용할 수 있게 되며, where 조건으로 사용할 수 있다.
            - 즉, 아래 예시와 같이 특정 일자만 골라 조회할 수 있게 된다.

                ```sql
                select 
                	count(1)
                from 
                	`firebase-public-project.analytics_153293282.events_*`
                where
                	_table_suffix = '20181003'
                ```

    - 이벤트 골라 읽기
        - 발생시키고 저장한 정보들 - 이벤트 이름이나 파라미터 등을 조건으로 데이터를 조회할 수 있다.
        - 이벤트 이름을 조건으로 조회

            ```sql
            SELECT
              count(event_params) event_count
            FROM 
              `firebase-public-project.analytics_153293282.events_*`
            WHERE
              event_name = 'screen_view'
            ```

        - 파라미터 특정 키의 특정 값을 조건으로 조회

            ```sql
            SELECT
              count(event_params) event_count
            FROM 
              `firebase-public-project.analytics_153293282.events_*`
            WHERE
              (select value.string_value from	unnest(event_params) where key = 'firebase_screen_class') = 'shop_menu'
            ```

### References

주의! Firebase와 관련된 모든 문서는 번역된 한글 문서 대신 영어로 보는 것을 권장한다. 번역이 상당히 늦게 진행되어 다른 정보를 가질 때가 많았다. 

- Example
    - [firebase-pulic-project bigquery dataset](https://console.cloud.google.com/bigquery?project=firebase-public-project)
- Development Guide
    - [Get started with Google Analytics](https://firebase.google.com/docs/analytics/get-started?platform=android)
    - [Usage and limits](https://firebase.google.com/docs/firestore/quotas)
    - [Link BigQuery to Firebase](https://support.google.com/firebase/answer/6318765?hl=en)
- Firebase Events
    - [Automatically collected events](https://support.google.com/firebase/answer/9234069?hl=en&visit_id=637440611134789939-3442272568&rd=1)
    - [Collection and configuration limits](https://support.google.com/firebase/answer/9237506?hl=en)
- BigQuery
    - [Querying multiple tables using a wildcard table](https://cloud.google.com/bigquery/docs/querying-wildcard-tables)