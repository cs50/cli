server {
    index index.php index.html;
    listen 80 default_server;
    location / {
        try_files $uri $uri/ @app;
    }
    location @app { try_files /index.php?$query_string =404; }
    location ~ \.php$ {
        fastcgi_index index.php;
        fastcgi_param HTTP_X_FORWARDED_HOST $host;
        fastcgi_param HTTP_X_FORWARDED_SERVER $host;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param SERVER_NAME $host;
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        include /etc/opt/server50/nginx/fastcgi_params;
        try_files $uri =404;
    }
    root <?= $root ?>;
    server_name localhost;
}
