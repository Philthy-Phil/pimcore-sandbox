# Install a Pimcore v10

### first step prepare your data
<pre>
setup your credentials in .env File for your setup
</pre>
### second step run deploy-script when docker client is running on your system
<pre>
sh deploy.sh <_STACKNAME_>
</pre>

### DONE!

<br />
<br />
<br />
<br />
<br />

### Additional Info
#### Docker-Compose consists of the following images:
<pre>
- Redis
- MariaDB 10.6.4
- Apache
</pre>


#### init and startup containers
<pre>
docker stack deploy -c docker-compose-pimcore.yml <_STACKNAME_>
</pre>


#### exec in pimcore-container
<pre>
docker exec -it <_PIMCORE CONTAINER_> bash
</pre>


#### install create composer-project for older pimcore (specific package)
> lookup https://packagist.org/packages/dpfaffenbauer/pimcore-skeleton


#### update composer for enhancing performance (if necessary)
<pre>
composer self-update
</pre>


#### create new project
<pre>
COMPOSER_MEMORY_LIMIT=-1 composer create-project pimcore/skeleton tmp
</pre>


#### fix folder structure
<pre>
mv tmp/.[!.]* . && mv tmp/* . && rmdir tmp
</pre>


#### install pimcore
<pre>
./vendor/bin/pimcore-install --mysql-host-socket=db --mysql-username=pimcore --mysql-password=pimcore --mysql-database=pimcore
</pre>


#### After the installer is finished, you can open in your Browser:
<pre>
Frontend: http://localhost:5000
Backend: http://localhost:5000/admin
Adminer: http://localhost:5002
</pre>


#### Common Errors

- File permissions

<pre>
docker exec -it <_PIMCORE CONTAINER_> bash 
chown www-data: . -R 
</pre>


#### Additional

<pre>
composer req symfony/maker-bundle --dev
</pre>

<pre>
// add in config > bundles.php
Symfony\Bundle\MakerBundle\MakerBundle::class => ['dev' => true],
</pre> 