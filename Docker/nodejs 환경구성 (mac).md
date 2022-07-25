# Node.js 환경구성 (mac)

소스 컴파일을 위한 Nodejs 환경구성을 docker 통해서 진행하는 방법 정리   


1. docker 다운로드 및 설치
2. visual code/ intelliJ 다운로드 및 설치 
3. Docker nodejs 실행
    ```
    #docker run -d -it --restart=always --name node_app -v [내 PC 저장경로]:[docker 내부 경로] node:[버전]
    
    docker run -d -it --restart=always --name node_app -v /Users/wm-bl000126/nodejs:/app node:14.16.1 
    ```
    ### 명령어 설명
    `docker run` : docker 실행   
    
    `-d` : detach모드 보통 데몬 모드라고 부르며, 컨테이너가 백그라운드로 실행 
    
    `-it` : 표준입력을 활성화하며, 컨테이너와 연결되어 있지 않더라도 표준 입력을 유지   
        _→ 보통 이 옵션을 사용하여 Bash에 명령어를 입력_   
    
    `--restart=always` : 컨테이너 종료시, 재시작 정책을 설정   
    
    `--name node_app` : 컨테이너 이름을 node_app으로 설정  
    
    `-v /Users/wm-bl000126/nodejs:/app` : 데이터 볼륨을 설정   
        _→ 호스트와 컨테이너의 디렉토리를 연결하며, 파일을 컨테이너에 저장하지 않고 호스트에 바로 저장_
    
    `node:14.16.1` : node 14.16.1 버전 설치    

<br>

4. intellij 실행
   1. 새 프로젝트를 열어 [내 PC 저장 경로] 에 작업할 폴더 생성   
      → [내 PC 저장 경로] : **/Users/wm-bl000126/nodejs**
   ```
      /Users/wm-bl000126/nodejs mkdir test
      /Users/wm-bl000126/nodejs cd test
      /Users/wm-bl000126/nodejs/test  
   ```
   작업 폴더 생성시 컨테이너의 /app 경로에도 동일하게 test 폴더가 생성
   
   2. intellij 내부 터미널에서 아래의 명령어 입력
   ```
      docker exec -it node_app /bin/bash
   ```
   
   3. docker 컨테이너 내부의 생성한 폴더로 이동하여 npm init을 통해 신규 프로젝트 생성
   ```
   root@0f5a303247c5:/app# cd /test
   root@0f5a303247c5:/app/test# npm init
   ```
   4. npm run을 통해서 실행 확인
   ```
   root@0f5a303247c5:/app/test# npm run test
   ```
   5. 확인 (아래처럼 뜨면 정상)
   ```
   > test@1.0.0 test /app/test
   > echo "Error: no test specified" && exit 1
   
   Error: no test specified
   npm ERR! code ELIFECYCLE
   npm ERR! errno 1
   npm ERR! test@1.0.0 test: `echo "Error: no test specified" && exit 1`
   npm ERR! Exit status 1
   npm ERR!
   npm ERR! Failed at the test@1.0.0 test script.
   npm ERR! This is probably not a problem with npm. There is likely additional logging output above.
   npm WARN Local package.json exists, but node_modules missing, did you mean to install?
   
   npm ERR! A complete log of this run can be found in:
   npm ERR!     /root/.npm/_logs/2022-07-25T09_58_13_187Z-debug.log

   ```
   
