# Http server

Small implementation of a http server using:
 - eio
 - piaf
 - yojson

The goal of this server is to make some benchmarks

The server has two endpoints:
 - "/route-a" : only returns an empty response
 - "/route-b" : does serialization and deserialization 

Benhmark tests with `wrk`

# How to start:

```
$ nix develop -c $SHELL
$ dune exec src/bin/main.exe
```

I am providing two benchmarks which run during 15 seconds:
```
$ ./bench-empty.sh # sends request to route-a
$ ./bench-non-empty.sh # sends request to route-b
```

With an empty endpoint the performance reach 30k req/s
With the other one the performance only reach 18k req/s

I am running these tests with 512 clients and 8 threads as the tests made by this [site](https://web-frameworks-benchmark.netlify.app/result) 

## Benchamrk results:

### Route-a
(the empty endpoint)

```
Running 15s test @ http://localhost:8080/route-a
  8 threads and 512 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    61.35ms  240.87ms   2.84s    95.97%
    Req/Sec     3.67k     1.77k   30.05k    90.95%
  435726 requests in 15.07s, 15.79MB read
Requests/sec:  28913.09
Transfer/sec:      1.05MB
```

### Routes-b
(the non empty endpoint)

```
Running 15s test @ http://localhost:8080/route-b
  8 threads and 512 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   148.36ms  526.16ms   5.17s    94.37%
    Req/Sec     2.20k     1.48k   16.27k    90.30%
  254649 requests in 15.08s, 24.77MB read
Requests/sec:  16887.65
Transfer/sec:      1.64MB
```