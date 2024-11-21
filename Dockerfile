FROM almalinux:8

RUN yum update -y && yum install -y nginx
COPY ./html /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
