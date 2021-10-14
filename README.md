# Aplicação web do Formulário de Pesquisa Clínica Uniforme


Configuração e programas necessários para rodar a aplicação localmente

* **Laravel**
	* Baixe e instale o [XAMPP](https://www.apachefriends.org/pt_br/download.html)
	* Baixe e instale o [Composer](https://getcomposer.org/download/)
	* Na pasta do Laravel rode o comando para instalar as bibliotecas necessárias para o laravel
	
		```
        composer install
        ```
    * Crie uma cópia do arquivo .env.example e renomeio-o apenas para .env
    * Ainda dentro da pasta, rode o comando
    	```
        php artisan key:generate
        ```
    * Abra o XAMPP e inicialize o Apache e o MySQL 
    * Acesse o [phpMyAdmin](http://localhost/phpmyadmin/index.php?lang=pt)
    * Ao entrar, crie um novo banco de dados com o nome que desejar
	* No seu arquivo .env, coloque em DB_DATABASE o nome do banco que você criou, em DB_USERNAME coloque root e em DB_PASSWORD deixe vazio
    * Após criar o banco, ele será listado à esquerda do phpMyAdmin. Clique no seu banco de dados e em seguida na guia SQL desse bd
    * No campo que irá aparecer, cole o script de criação do banco de dados que está no Google Drive e execute-o
    * Após isso, podemos servir o projeto Laravel com o comando
		```
        php artisan serve
        ```
    * obs.: Nas próximas vezes que for servir o laravel basta apenas inicializar o Apache e o MySQL e rodar o comando acima


* **React**
	* Baixe e instale o [NodeJS](https://nodejs.org/en/download/)
	* Instale o [Yarn](https://classic.yarnpkg.com/en/docs/install)
	* Dentro da pasta do React, rode o comando 
		```
        yarn install
        ```
    * Com isso você já pode servir a aplicação react com
		```
        yarn start
        ```
    * obs.: Nas próximas vezes que for servir o react basta apenas rodar o comando para servir

	Com os dois projetos sendo servidos você pode acessar a aplicação no localhost:3000(pode ser que esteja em outra porta, ao servir o react vai ser mostrado)
   
      
