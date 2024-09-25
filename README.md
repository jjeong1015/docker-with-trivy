# DockerTrivy

## 🔍 Trivy란?
Trivy는 오픈소스 보안 스캐너로, 컨테이너 이미지, 파일 시스템, Git 리포지토리 등 다양한 소스에서 보안 취약점을 탐지하는 데 사용한다. Docker 이미지와 같은 컨테이너화된 애플리케이션의 취약점을 스캔하는 데 유용하며, 운영체제 패키지와 애플리케이션 의존성에서 발생할 수 있는 보안 문제를 빠르고 간편하게 찾아낸다.

## 🤔 Trivy를 왜 사용해야 하는가?
애플리케이션이 배포되기 전에 **보안 취약점을 식별하고 수정하여 안전한 환경에서 서비스를 운영**할 수 있다.

## 🛠️ 목표
Docker를 통해 Spring Boot 애플리케이션을 컨테이너로 배포하고, Trivy를 사용해보며 보안 스캔을 자동화한 워크플로우를 제공한다. 또한 GitHub Actions를 이용해 CI/CD 파이프라인을 구축하여, 코드를 커밋하는 순간 자동으로 보안 스캔까지 진행하는 환경을 구성한다.

## 🐋 Docker 설치
```bash
# 1. apt 인덱스 업데이트
$ sudo apt-get update
$ sudo apt-get install ca-certificates curl gnupg lsb-release

# 2. Docker 공식 GPG 키 추가
$ sudo mkdir -m 0755 -p /etc/apt/keyrings
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# 3. Docker 저장소를 APT 소스에 추가
$ echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 4. APT 패키지 캐시 업데이트
$ sudo apt-get update

# 5. Docker 서비스 상태 확인
$ sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 6. 사용자 권한 설정
$ sudo usermod -aG docker $USER # docker 명령어 사용시 sudo 권한 부여하는 설정(재부팅 필수)
$ newgrp docker    # 설정한 그룹 즉각 인식하는 명령어, 생략시 재부팅 후에만 group 적용
$ groups
$ tail /etc/group

# 7. 설치 확인
$ docker --version
```
## 🚀 Docker에 Spring Boot 애플리케이션 배포
1. 프로젝트 디렉토리 생성 및 이동
```bash
$ mkdir dockerTrivy

$ cd dockerTrivy
```
```bash
$ cd scanDockerImage

$ touch Dockerfile
```
2. Dockerfile 작성
```bash
# Dockerfile

# Step 1: Build stage
FROM openjdk:17-jdk-alpine AS build

# 작업 디렉토리 생성
WORKDIR /usr/src/myapp

# Gradle Wrapper와 관련 파일 복사
COPY gradlew /usr/src/myapp/
COPY gradle /usr/src/myapp/gradle/

# 소스 코드 복사 (src 디렉토리 및 필요한 다른 파일 복사)
COPY . /usr/src/myapp

# Gradle Wrapper에 실행 권한 부여
RUN chmod +x ./gradlew

# Gradle 빌드 실행
RUN ./gradlew clean build --no-daemon

# Step 2: Run stage
FROM openjdk:17-jdk-alpine

# 작업 디렉토리 생성
WORKDIR /usr/src/myapp

# 빌드된 JAR 파일을 복사 (ScanDockerImageApplication.jar로 이름 지정)
COPY --from=build /usr/src/myapp/build/libs/*.jar /usr/src/myapp/ScanDockerImageApplication.jar

# 포트 노출 (Spring Boot 기본 포트)
EXPOSE 8080

# JAR 파일 실행 명령어
CMD ["java", "-jar", "/usr/src/myapp/ScanDockerImageApplication.jar"]
```
3. Docker 이미지 빌드 및 실행
```bash
$ docker build -t scan-docker-image .
```
![111](https://github.com/user-attachments/assets/111652fc-ac14-4dea-b411-be915f8060e8)
```bash
$ docker run -d -p 8080:8080 scan-docker-image
```
![222](https://github.com/user-attachments/assets/31cf7940-0de9-4a60-bc50-fec8f2d6032d)
![333](https://github.com/user-attachments/assets/c6232023-04a7-4d2e-b0c0-d41f8042740d)
![444](https://github.com/user-attachments/assets/4afc05d9-f652-488b-a0d6-6308f9bbbe71)
## 🔍 Trivy로 보안 스캔하기
```bash
# Trivy 이미지 다운로드
$ docker pull aquasec/trivy

# 이미지 보안 스캔 실행
$ docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image scan-docker-image
```
![image](https://github.com/user-attachments/assets/a20d0051-dd4b-481e-bca0-74537080222c)
## 🛠️ GitHub Actions 연동하여 CI/CD 자동화
```bash
# .github/workflows/trivy-scan.yml
name: Security Scan

on:
  push:
    branches:
      - main
  pull_request:

jobs:
  trivy-scan:
    runs-on: ubuntu-latest

    steps:
      # 소스 코드 체크아웃
      - name: Checkout code
        uses: actions/checkout@v2

      # Docker 이미지 빌드
      - name: Build Docker image
        run: docker build -t ScanDockerImageApplication .

      # Trivy 설치
      - name: Install Trivy
        run: |
          sudo apt-get update && sudo apt-get install -y wget
          wget https://github.com/aquasecurity/trivy/releases/latest/download/trivy_Linux-64bit.deb
          sudo dpkg -i trivy_Linux-64bit.deb

      # Docker 이미지 보안 스캔 실행
      - name: Scan Docker image for vulnerabilities
        run: trivy image ScanDockerImageApplication
```
## 🌐 GitHub 리포지토리 연동
```bash
# Git 설치
$ sudo apt update
$ sudo apt install git

# 사용자 정보 설정
$ git config --global user.name "사용자 이름"
$ git config --global user.email "사용자 이메일"

# 리포지토리 초기화 및 원격 저장소 연동
$ git init
$ git remote add origin https://github.com/jjeong1015/DockerTrivy.git

# 커밋 및 푸시
$ git add .
$ git commit -m "feat: commit message"
$ git branch -M main
$ git push -u origin main
```
