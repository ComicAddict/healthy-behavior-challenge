# README

1. [deployed app](https://hbc-f855dfc7b6d2.herokuapp.com/)
      - Instructor Credentials:
           ```
           Email :  healthybehaviorchallenge@gmail.com
           Password : asdf
           ```
     - You can add your own credentials for trainee accounts
     - From there you should be able to use all the features of the app
2. Code Climate Reports
      - [Link to rubocop report](https://drive.google.com/file/d/1NIKxQ7L5d2Z-Bvtc3XkgI9SvOUgWsEpp/view?usp=sharing)
      - [Link to RSPEC coverage report](https://drive.google.com/drive/folders/1-cmpYC1cz5VsGO3EU0Q846kFAJdKuQLM?usp=drive_link)
3. Cloning the Repository
      - Please visit https://github.com/shweta-sharma-tamu/healthy-behavior-challenge to clone our project. 
      - You will be able to find all these instructions in the google document attached at last. 
      - Command to clone :
        ```
        git clone https://github.com/shweta-sharma-tamu/healthy-behavior-challenge
        ``` 
4. Know how to get started with Development
     - We have our project executed using docker containerization. So one has to follow below steps to install and get started with docker for development of our project.
     - Please refer to this link to install docker based on your system specifications: ``` https://docs.docker.com/desktop/install/mac-install/ ```
     - Verify docker installation using  ``` docker --version ```
     - ``` cd healthy-behavior-challenge ```
     - Duplicate ``` .env.template ``` file and save in same location with name as ``` .env ```
     - Run ``` docker compose up ```
     - Go to the docker container service: 'web' (which is our rails container). Access it as terminal by docker exec command or docker desktop application.
        - Follow below steps:
          ```
          docker ps
          docker exec -it 82db16d3c448 /bin/bash  (provide ID of your docker container in place of 82db16d3c448)
          ```
        - Now you will be on rails container
     - Run ``` rails simple_discussion:install:migrations ``` from rails container
     - Run ``` rails db:migrate ``` from rails container
     - Run ``` rails db:seed ``` from rails container ( for default instructor credentials )
         - Credentials :
           ```
           Email :  healthybehaviorchallenge@gmail.com
           Password : asdf
           ```
     - To access the app locally : ``` http://localhost:3000/ ``` and use above provided credentials to login. 


5. Know how to run tests
     - Please make sure ``` .env ``` file is correct
     - Run your test commands in the terminal of the rails container.
        - To do so follow as below :
          ```
          docker ps
          docker exec -it 82db16d3c448 /bin/bash (provide ID of your docker container in place of 82db16d3c448)
          ```
        - You will be on rails container
     - Run cucumber tests with ``` RAILS_ENV=test cucumber -s ```
     - Run rspec tests with ``` RAILS_ENV=test bundle exec rspec ```
     - You can find coverage report in ``` coverage/ ``` folder in root directory

       
6. Coverage Report
     - The comprehensive test coverage needs to run Rspec and cucumber. You will see the coverage percentage after run two commands. 
     - Running Rubocop :
         - Run the following command to execute Rubocop:
           ```
           bundle exec rubocop
           ```
         - Rubocop will analyze your codebase and display any style violations or offenses in the terminal.
     - Running Rubycritic :
         - Run the following command to generate the code quality report:
           ```
           bundle exec rubycritic
           ```
         - Rubycritic will analyze your codebase and generate an HTML report containing a summary of the code quality metrics. The report is usually saved in the tmp/rubycritic directory.


7. Know how to deploy our project both locally and online:
    - Check [DEPLOYMENT.md](https://github.com/ComicAddict/healthy-behavior-challenge/blob/main/DEPLOYMENT.md)
    - ``` cd healthy-behavior-challenge ```
    - Login to heroku through CLI
      ```
      heroku login
      ```
    - Create the app on heroku
      ```
      heroku create your-app-name
      ```
    - Deploy to heroku
      ```
      git push heroku main
      ```
    - Go to heroku and add-on postgres from resources
    - Go to settings -> configuration variables
    - Add a configuration variable PROJECT_EMAIL and add value as your email
    - Add a configuration variable PROJECT_PASSWORD and add value as your gmail app password
    - Run migrations
      ```
      heroku run rails simple_discussion:install:migrations
      heroku run rake db:migrate
      ```
    - App is deployed. One can open the app through this cmd
      ```
      heroku open
      ```
    - You can find our deployed app here:
      https://hbc-f855dfc7b6d2.herokuapp.com/
      
9. Know How to Use the Web application
    - We have Two Modules :
       - Instructor(Gym Instructor)
         - Can Create/Edit Challenge
         - Add participants to a challenge
         - Refer Another Instructor to sign up
       - Trainee
         - Signup/Login
         - Update Todo List per day
         - Check progress
    - Actions you may perform to know features of our app:
       - As an Instructor:
         -  Log in using the existing default credentials mentioned above
         -  on successful login, you should be able to see :
            -  Ongoing Challenges
               - click on any displayed challenge to know more details of a challenge, Edit challenge, show participants & their progress 
            -  Past Challenges button
            -  Upcoming Challenges button
            -  Nav bar with My profile: to see profile details
            -  Nav bar with Refer instructor :
               - enter the email of the new instructor and submit
               - new instructors will receive a referral link to their email, click on it, enter the details and that new instructor can login now.
            -  Create Challenge bottom right corner: to create a new challenge
            -  Nav bar with Signout to log out from the session
      - As a Trainee:
        - Sign up if new user by entering all required fields
        - Log in with the credentials
        - Will be able to see the Date field, select a specific date, and click on Show tasks will display tasks for that date. Mark as complete will be disabled for all dates except the current days and the previous day till the current date's 3 AM.
        - On current day, they should be able to mark tasks as completed
        - They can see the streak and also the report which tracks their weekly report.

   
10. Contact Us for any queries: Please reach out to any one of us if you have any queries
    - Tolga Yildiz (tolgayildiz@tamu.edu)
    - Mackenzie Hamlett (mackenziehamlett@tamu.edu)
    - Jakob Kirby (kirbyj3684@tamu.edu)
    - Chenxin Li (Lee1151341952@tamu.edu)
    - Francis Bui (francisthienbui@tamu.edu)
    - Michael Chiu (mchiu@tamu.edu)
    - Fizza Ali (fizza@tamu.edu)
