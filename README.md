# cnv

Converts numbers in the command line.
```bash
$ cnv 123
123 0x7b 0b1111011 (9 bits)
$ cnv 0xDEADBEEF
3735928559 0xdeadbeef 0b11011110101011011011111011101111 (34 bits)
$ cnv 0b10101010
170 0xaa 0b10101010 (10 bits)
```

# Build cnv

```
git clone git@github.com:jdmichaud/cnv.git
cd cnv
zig build
```

`cnv` will be built in `zig-out/bin/cnv`

