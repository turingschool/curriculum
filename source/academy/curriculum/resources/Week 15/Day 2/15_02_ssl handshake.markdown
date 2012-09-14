---
layout: page
title: SSL Handshake
---

## SSL Handshake

1. Client Request with random seed and supported protocols
2. Server response with protocol, random number, certificate
3. Client verifies, sends it's own public key encrypted with the server's public key
4. Client makes application-level request encrypted with seed and key
4. Server verifies, prepares response, sends encrypted response.