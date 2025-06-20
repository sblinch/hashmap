module github.com/cornelk/hashmap/benchmarks

go 1.22

toolchain go1.24.4

replace github.com/cornelk/hashmap => ../

require (
	github.com/alphadose/haxmap v1.4.1
	github.com/cornelk/hashmap v1.0.8
	github.com/puzpuzpuz/xsync/v2 v2.5.1
	github.com/zhangyunhao116/skipmap v0.10.1
)

require (
	github.com/zhangyunhao116/fastrand v0.3.0 // indirect
	golang.org/x/exp v0.0.0-20221031165847-c99f073a8326 // indirect
)
