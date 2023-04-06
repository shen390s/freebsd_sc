= README for sc tool

1. Generate configuration

```sh
./bin/sc mkconfig 
```
   You can edit generated configuration file to meet your
   requirements.  
   
2. Initialize of service host

```sh
./bin/sc -f <sc.conf> init 
```

   This command will initialize current host as server  host.(You
   should add current host to servers list in sc.conf)
   
3. Build service image

```sh
./bin/sc -f <sc.conf> build <role>
```

4. Export built image

```sh
./bin/sc -f <sc.conf> export <role>
```

5. Configure role

```sh
./bin/sc -f <sc.conf> config <role>
```

6. Deploy role

```sh
./bin/sc -f <sc.conf> deploy <role>
```
