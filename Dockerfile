FROM golang:alpine AS build-env
WORKDIR /go/src
COPY . /go/src/app/
RUN set -xe \\
    && apk add --no-cache bash git
RUN go get -u github.com/golang/dep/cmd/dep

WORKDIR /go/src/app
RUN dep init
RUN go build main.go
#go build command creates a linux binary that can run without any go tooling.

FROM alpine
#Alpine is one of the lightest linux containers out there, only a few MB
RUN apk update && apk add ca-certificates && rm -rf /var/cache/apk*
WORKDIR /app
COPY --from=build-env /go/src/app/main /app
COPY --from=build-env /go/src/app/form /app/form
#COPY --from=build-env /go/src/welcome-app/static /app/static
#Here we copy the binary from the first image (build-env) to the new alpine container as well as the html and css

EXPOSE 3000
ENTRYPOINT [ "./main" ]


# UNCOMMENT FOR TUTORIAL 4b

# FROM "golang:alpine"
# # Here the FROM clause states which base image we are intending to work with. If the image does not exist, locally, Docker automatically fetches it from Dockerhub. If you supplied a URI for the image, Docker will download it from there too. Here we begin with the xxx image

# MAINTAINER "Martin Ombura <info@martinomburajr.com"
# # Shows who created/maintains the file

# WORKDIR /go/src
# # Tells Docker to create a working directory that the container will by default use for your project. When you docker -ti <image> it will check into this folder first

# COPY . /go/src
# # This command tells Docker to copy files from our local machine, into the container that is being built. In some cases we can choose to download our code from Github or any other source, for our case it is simple enough to just COPY the welcome-app to Docker. and place it in the WORKDIR mentioned earlier.

# RUN cd /go/src && go build -o main
# # Check into our working directory, build our main.go

# EXPOSE 3000
# # This tells Docker to expose a certain port that can be listened to. This is important since our application is exposing on Port 3000, we need Docker to also expose on this port so that external sources can interact with our app.

# ENTRYPOINT "./main"
# # This is the first command to run once the container starts, turning it into an automatically running welcome-app server.


# To run use the command below
# docker build -t imagename:version .
