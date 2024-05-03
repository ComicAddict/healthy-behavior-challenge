# Local Deployment

1. Install Docker
	https://docs.docker.com/desktop/install/windows-install/
	https://docs.docker.com/desktop/install/mac-install/
	https://docs.docker.com/desktop/install/linux-install/
2. Continue Without Sign In
3. Skip Survey
4. Open Terminal
5. Verify docker installation by running ```docker --version```
6. Run ```git clone https://github.com/ComicAddict/healthy-behavior-challenge.git```
7. Run ```cd healthy-behavior-challenge```
8. Duplicate ```.env.template``` file and save in same location with name as ```.env```
Linux-Max: ```cp .env.template .env```
Windows: ```copy .env.template .env```
9. Run ```docker compose up```
10. Wait until all containers are built
11. start another terminal
12. Run ```docker ps``` and copy the 'CONTAINER ID' of the IMAGE name ```healthy-behavior-challenge-web```
13. Run ```docker exec -it <insert container id here> /bin/bash```
14. This will give a terminal access to the docker environment whic the app is running.
15. Run ```rails db:migrate```
16. Run ```rails db:seed```
17. Open http://localhost:3000/ to see the deployed app
18. Credentials are:
```
Email :  healthybehaviorchallenge@gmail.com
Password : asdf
```

# Running tests
1. Set ```RAILS_ENV=test```
1. For Cucumber Tests Run:
```cucumber -s```
2. For RSPEC Tests Run:
```bundle exec rspec```
3. For Rubocop Run:
```bundle exec rubocop```
4. For Rubycritic Run:
```bundle exec rubycritic```

# Remote Deployment
1. Run ```heroku login```
2. Run ```heroku create your-app-name```
3. Run ```git push heroku main```
4. Go to heroku and add-on postgres from resources
5. Go to settings -> configuration variables
6. Add a configuration variable ```PROJECT_EMAIL``` and add value as your email
7. Add a configuration variable ```PROJECT_PASSWORD``` and add value as your gmail app password
8. Run migrations
```
heroku run rails simple_discussion:install:migrations
heroku run rake db:migrate
```
10. App is deployed. One can open the app through this cmd
```heroku open```
