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