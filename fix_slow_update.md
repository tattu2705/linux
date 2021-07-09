# Fix slow update connection:

```shell
    sudo vi /etc/apt/sources.list
```

delete all lines with ```:%d```
then enter those lines:

```
    deb http://kali.download/kali kali-rolling main contrib non-free 
    deb-src http://kali.download/kali kali-rolling main contrib non-free
```

or you can change the http://kali.download/kali to any mirrors [here](http://http.kali.org/README.mirrorlist)
select the mirror which have highest ```prio```

save the file, then:
```shell
    sudo apt clean
    sudo apt update -y
```
