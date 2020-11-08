---
layout: post
title: github pages + jekyll로 블로그 제작하기
subtitle: github pages + jekyll (+ cloud9)
keywords: github pages, jekyll, lanyon, aws, cloud9, ide, blog
---


블로그 제작을 쉽고 빠르게 하면서도 입맛에 맞는 기능을 갖추기 위해 github pages, jekyll, cloud9을 사용했다.
google 검색 결과 노출 후 유입에 최적화하고 유입 이후의 읽기 외 기능을 모두 간결하게 정리하는 것이 주요한 요구사항이었으며, 부가적으로 글쓰기/배포 환경의 편의를 위해 로컬 작업환경이 아닌 온라인 인스턴스에 Cloud9 IDE를 구성해 추가하였다.
추후 신규 웹사이트 생성 혹은 반복 작업이 이뤄질 때를 위하여 빠르게 따라할 수 있도록 작업 과정을 순서대로 나열하였다.

---


## 작업 진행


### 테마 검색
- [http://jekyllthemes.org](http://jekyllthemes.org/), [https://jekyllthemes.io](https://jekyllthemes.io/), [http://themes.jekyllrc.org](http://themes.jekyllrc.org/) 등에서 테마 검색
- 컨텐츠 읽기에 적합한 테마 → [https://lanyon.getpoole.com](https://lanyon.getpoole.com/)
- 영문에 맞춰진 font 설정 대신 한글이 잘 보일 수 있도록 CSS 수정 (size, line height 조정)


### Cloud9 설정 (Optional)
1. AWS Console 접속 → cloud9 검색, 이동
    ![medium](/assets/2020/aws-console.png)
2. AWS Cloud9 인스턴스 생성 클릭
    ![medium](/assets/2020/aws-cloud9-console-greeting.png) *Cloud9 첫 화면*

    ![medium](/assets/2020/aws-cloud9-create.png) *Cloud9 생성 시 설정들*
    - Environment type : 접속 환경 설정
    - Instance type : 머신 성능 설정
    - 플랫폼 : 운영체제 설정
    - Cost Saving setting : 일정 시간 사용하지 않는 경우 동작을 멈추도록 설정한다. 
    
    ![medium](/assets/2020/aws-cloud9-created.png) *생성 완료된 IDE*
    
    ![medium](/assets/2020/open-cloud9-ide.png) *cloud9 접속 중인 화면*
    
    ![medium](/assets/2020/hello-cloud9.png) *cloud9 첫 화면*
    
    - 첫 화면 이후 Tools → Terminal 선택하여 터미털 창을 실행한다.


### Jekyll 설치

1. Ruby install
    - [Installing Ruby](https://www.ruby-lang.org/en/documentation/installation/) 웹페이지 방문, 운영체제에 맞춰 링크 선택
    ```
    // Cloud9 기본 설정의 경우 CentOS
    sudo yum install ruby
    ```
    - 루비 설치 완료 확인
    ```
    ruby -v
    // 결과로 "ruby 2.6.3p62 (2019-04-16 revision 67580) [x86_64-linux]" 출력되면 정상
    ```
2. Jekyll install
    - [Jekull Installation](https://jekyllrb.com/docs/installation/) 웹페이지 참고
    ```
    gem install jekyll bundler
    ```


### Theme 설치

1. Theme download
    - lanyon theme 사용
    ```
    git clone https://github.com/poole/lanyon
    ```
2. Plugin install 
    - 테마가 요구하는 플러그인을 먼저 설치
    ```
    bundle install
    ```


### Start Editing

1. jekyll 시작
    ```
    jekyll serve --port 8080
    ```
    - 기본 포트는 3000, cloud9 외부 접속을 위한 포트는 제한적 → 8080으로 여는 경우 즉시 연결 가능한 URL이 제공된다.
    ```
    jekyll server --livereload
    ```
    - 소스 변경 시 자동 업데이트, cloud9 기본 설정 상태에서 사용 불가.
2. Config 수정
    - 기본 테마의 설정들을 모두 수정한다. 
    - Google Analytics messurement id 등이 기본값으로 등록되어 있다. 
3. header 수정
    - 헤더 파일에 기본적인 스크립트와 스타일, Google analytics 설정이 포함되어 있다. (경로는 → /_includes/head.html)
    - 몇 가지 스타일 수정을 위해 custom.css 파일을 생성하고 헤더에 삽입한다. 
    
    ```html
    <link rel="stylesheet" href="{{ '/public/css/custom.css' | relative_url }}">
    ```

    - 기본 설정의 경우 gtag.js 가 아닌 ga.js로 기본 설정되어 있다. → gtag 스타일로 변경한다.
    
    ```html
    <!--as-is-->
    <script>
        (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
        (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
        m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
        })(window,document,'script','//www.google-analytics.com/analytics.js','ga');
        ga('create', '{% raw %}{{ site.google_analytics_id }}{% endraw %}', 'auto');
        ga('send', 'pageview');
    </script>

    <!-- to-be -->
    <script>
    window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag('js', new Date());
    
    gtag('config', '{% raw %}{{ site.google_analytics_id }}{% endraw %}');
    </script>
    ```
    
    - 기존 스크립트와 동일하게 `{% raw %}{{ site.google_analytics_id }}{% endraw %}` < 트래킹 아이디를 별도의 변수로 추가한다. 해당 변수는 /_config.yml 파일에서 수정한다.
        

### Github Pages
1. 저장소 생성
    - github repository 생성 → [링크](https://github.com/new)
    ![medium](/assets/2020/github.com_new.png)

    - repository의 이름이 `사용자이름.github.io` 으로 생성되어야 한다. (필수)
    

2. git push
    -  gh-pages 브랜치를 생성한다. 
    -  origin에 push한다. 

3. github setting
    - github 저장소 → Setting → GitHub Pages → Source → branch gh-pages 선택

4. 잠시 대기 
    - push 직후 빌드가 진행된다. 
    - 잠시 기다리면 제작한 웹사이트가 000.github.io에 띄워진 것을 확인할 수 있다.
