az acr credential show --name marketflowregistry
{
  "passwords": [
    {
      "name": "password",
      "value": "***"
    },
    {
      "name": "password2",
      "value": "***"
    }
  ],
  "username": "marketflowregistry"
}

docker login marketflowregistry.azurecr.io \
  -u marketflowregistry \
  -p "***"

docker build -t marketflowregistry.azurecr.io/test:v0.0.1 .
[+] Building 2.3s (7/7) FINISHED                                                                                                                                  docker:default
 => [internal] load build definition from Dockerfile                                                                                                                        0.2s
 => => transferring dockerfile: 109B                                                                                                                                        0.0s
 => [internal] load metadata for docker.io/library/nginx:1.25-alpine                                                                                                        0.7s
 => [internal] load .dockerignore                                                                                                                                           0.2s
 => => transferring context: 2B                                                                                                                                             0.0s
 => [internal] load build context                                                                                                                                           0.2s
 => => transferring context: 31B                                                                                                                                            0.0s
 => [1/2] FROM docker.io/library/nginx:1.25-alpine@sha256:516475cc129da42866742567714ddc681e5eed7b9ee0b9e9c015e464b4221a00                                                  0.0s
 => CACHED [2/2] COPY index.html /usr/share/nginx/html/index.html                                                                                                           0.0s
 => exporting to image                                                                                                                                                      0.2s
 => => exporting layers                                                                                                                                                     0.0s
 => => writing image sha256:20e5db216d3d502aa0e3a64b5dd79c7adb1cd10bd7f558fa8c9ea75fca7d5a13                                                                                0.0s
 => => naming to marketflowregistry.azurecr.io/test:v0.0.1                                                                                                                  0.1s
(data-lab) kinga@mworker1:17:53:41:~/works/marketflow
> docker push marketflowregistry.azurecr.io/test:v0.0.1
The push refers to repository [marketflowregistry.azurecr.io/test]
df3689d231b0: Pushed 
ce495f7b0b7d: Pushed 
9c70f446fbe2: Pushed 
5be225e16e44: Pushed 
3d04ead9b400: Pushed 
af5598fef05f: Pushed 
8fbd5a835e5e: Pushed 
75061be64847: Pushed 
d4fc045c9e3a: Pushed 
v0.0.1: digest: sha256:b880c0069ec89326cc4988c9eb02c361732cdccb1bdb8d7d3ba09107367a406a size: 2196