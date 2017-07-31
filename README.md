# TidalP5

![Demo](demo.gif?raw=true)

```haskell
s1 $ slow 8 $ stack [
  s "point*50"
    |=| strokeWeight "5"
    |=| dur "8"
    |=| x (choose[0.1,0.2..0.9])
    |=| y (listToPat[0.1,0.2..0.9]),
  s "poly*50"
    |=| r "0.1"
    |=| dur "8"
    |=| n "4"
    |=| strokeWeight (scale 1 8 $ slow 4 $ sine1)
    |=| x (density 2 $ (listToPat[0.1,0.2..0.9]))
    |=| y (density 3 $ listToPat[0.1,0.2..0.9])
]

s2 $ stack [
  s "[polygon]*8"
    |=| strokeWeight (scale 0.1 2 $ slow 32 $ sine1)
    |=| r (scale 0 1 $ slow 9 $ zoom (0, 0.5) tri1)
    |=| dur (scale 5 3 $ slow 2 $ tri1)
    |=| rotate (scale 4 0 $ slow 4 $ zoom(0, 0.5) tri1)
    |+| rotate "0.1 0.3 0.5 0.8 0.9"
    |=| n "24"
]
```
