# Docker


## 1. Docker란
- Docker는 리눅스의 응용 프로그램들을 프로세스 격리 기술들을 사용해 컨테이너로 실행하고 관리하는 오픈소스 프로젝트   
- 컨테이너 안에는 다양한 프로그램, 실행 환경을 '컨테이너'라는 개념으로 추상화하고 클라우드, PC 등 어디서든 실행할 수 있다.   
- Docker에서 가장 중요한 개념은 컨테이너, 이미지이다.

## 1-1 Docker 이미지란?
- 컨테이너 실행에 필요한 파일, 설정값을 모두 포함

## 1-2 Docker 컨테이너란?
- 이미지를 실행하는 것
- 여기서 추가, 변화되는 값은 컨테이너에 저장
- 같은 이미지로 다수의 컨테이너를 생성할 수 있고 컨테이너의 변화가 생겨도 이미지에는 영향을 주지 않음
     
 ![Docker](/Docker/img/Docker.png)

## 2. Docker 설치 및 실행

### Docker 설치

1. Docker 공식 사이트에서 다운로드   
   [도커 공식 사이트](https://www.docker.com/get-started/)
2. Cli 설치 (Mac 기준)
    ```
   $ brew cask install docker
   ```
3. 설치 확인
    ```
   $ docker --version
   ```

### Docker 실행
- 다운로드 후 생긴 Docker Desktop 클릭   
_- 한번 실행해줘야 /usr/local/bin에 도커 링크가 생기고, 터미널에서 작업할 수 있다._   
![Docker Desktop](/Docker/img/Docker1.png)   
  ![Docker running](/Docker/img/Docker2.png)   
- 실행 후 상단 아이콘에 마우스를 갖다대면 "Docker desktop is running"으로 표시


## 3. 자주 사용하는 Docker Commands
> [참고 사이트] [Docker](https://docs.docker.com/engine/reference/commandline/docker/)

### 현재 실행중인 모든 컨테이너 목록 출력
   ```
   $ docker ps
   ```

### 실행과 상관없이 모든 컨테이너 목록 출력
   ```
   $ docker ps -al
   ```

### Docker image
   ```
   $ docker image                //다운받은 이미지 확인
   $ docker search 이미지 이름     //이미지 서치
   $ docker pull 이미지 이름       //이미지 다운로드
   $ docker rmi 이미지 이름        //이미지 삭제
   ```

### Docker container
   ```
   $ docker run 이미지 이름          //컨테이너 실행
   $ docker stop 컨테이너 이름        //컨테이너 종료
   $ docker restart 컨테이너 이름     //컨테이너 시작
   $ docker rm 컨테이너 이름          //컨테이너 삭제
   ```


## 4. Docker File
### Dokcerfile 관련 명령어

#### FROM
- 어떤 이미지를 기반으로 할지 설정
- Docker 이미지는 기존에 만들어진 이미지를 기반으로 생성한다.
- 완전히 새로운 이미지를 생성하고 싶으면 `FROM scratch`를 사용

#### MAINTAINER
- 메인테이너(제작자) 정보


#### RUN
- 쉘 스크립트/명령을 실행
- 이미지 생성 중에는 사용자 입력을 받을 수 없으므로 `apt-get install`명령어를 사용할 경우 `-y`옵션을 사용

#### VOLUM
- 호스트와 공유할 디렉터리 목록
- `docker run` 명령어에서 `-v`옵션을 설정할 수도 있음

#### ADD
- 빌드시에 주어진 컨텍스트에서 첫번째 인자로 주어진 파일, 폴더를 두번째 인자로 주어진 컨테이너 경로에 추가

#### CMD
- 컨테이너가 시작되었을 때 실행할 실행 파일/ 쉘 스크립트

#### EXPOSE
- 호스트와 연결할 포트 번호
- 외부와 통신을 가능하게 노출
- 기본적으로 컨테이너 실행 시 `docker run -p` 옵션을 주게 되면 `EXPOSE`가 됨
