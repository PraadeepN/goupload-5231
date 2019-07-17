FROM scratch
EXPOSE 8080
ENTRYPOINT ["/goupload-5231"]
COPY ./bin/ /