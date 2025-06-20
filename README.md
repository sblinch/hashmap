# hashmap

[![Build status](https://github.com/cornelk/hashmap/actions/workflows/go.yaml/badge.svg?branch=main)](https://github.com/cornelk/hashmap/actions)
[![go.dev reference](https://img.shields.io/badge/go.dev-reference-007d9c?logo=go&logoColor=white&style=flat-square)](https://pkg.go.dev/github.com/cornelk/hashmap)
[![Go Report Card](https://goreportcard.com/badge/github.com/cornelk/hashmap)](https://goreportcard.com/report/github.com/cornelk/hashmap)
[![codecov](https://codecov.io/gh/cornelk/hashmap/branch/main/graph/badge.svg?token=NS5UY28V3A)](https://codecov.io/gh/cornelk/hashmap)

## Overview

A Golang lock-free thread-safe HashMap optimized for fastest read access.

It is not a general-use HashMap and currently has slow write performance for write heavy uses.

## Usage

Example uint8 key map uses:

```
m := New[uint8, int]()
m.Set(1, 123)
value, ok := m.Get(1)
```

Example string key map uses:

```
m := New[string, int]()
m.Set("amount", 123)
value, ok := m.Get("amount")
```

Using the map to count URL requests:
```
m := New[string, *int64]()
var i int64
counter, _ := m.GetOrInsert("api/123", &i)
atomic.AddInt64(counter, 1) // increase counter
...
count := atomic.LoadInt64(counter) // read counter
```

## Benchmarks

Reading from the hash map for numeric key types in a thread-safe way is faster than reading from a standard Golang map
in an unsafe way and three times faster than Golang's `sync.Map`:

```
ReadXsyncMapUint-8                924.5n ± ∞ ¹
ReadHashMapUint-8                 1.072µ ± ∞ ¹
ReadHaxMapUint-8                  1.296µ ± ∞ ¹
ReadGoMapUintUnsafe-8             1.318µ ± ∞ ¹
ReadGoSyncMapUint-8               3.389µ ± ∞ ¹
ReadSkipMapUint-8                 4.820µ ± ∞ ¹
ReadGoMapUintMutex-8              32.62µ ± ∞ ¹
```

Reading from the map while writes are happening:
```
ReadHashMapWithWritesUint-8       1.235µ ± ∞ ¹
ReadHaxMapWithWritesUint-8        1.433µ ± ∞ ¹
ReadGoSyncMapWithWritesUint-8     4.503µ ± ∞ ¹
```

Write performance without any concurrent reads:

```
WriteGoMapMutexUint-8             21.72µ ± ∞ ¹
WriteHashMapUint-8                27.99µ ± ∞ ¹
WriteGoSyncMapUint-8              78.43µ ± ∞ ¹
```

The benchmarks were run with Golang 1.24.4 on Linux and a Ryzen 9 5900X CPU using `make benchmark-perflock`.

## Technical details

* Technical design decisions have been made based on benchmarks that are stored in an external repository:
  [go-benchmark](https://github.com/cornelk/go-benchmark)

* The library uses a sorted linked list and a slice as an index into that list.

* The Get() function contains helper functions that have been inlined manually until the Golang compiler will inline them automatically.

* It optimizes the slice access by circumventing the Golang size check when reading from the slice.
  Once a slice is allocated, the size of it does not change.
  The library limits the index into the slice, therefore the Golang size check is obsolete.
  When the slice reaches a defined fill rate, a bigger slice is allocated and all keys are recalculated and transferred into the new slice.

* For hashing, specialized xxhash implementations are used that match the size of the key type where available
