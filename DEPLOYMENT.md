### Prerequisites:

1. **AWS Account:**
   - Ensure you have an AWS account. If not, you can create one at [https://aws.amazon.com/](https://aws.amazon.com/).

2. **S3**
    TODO

3. **CloudFront**
    TODO

### Deploying Ruby Script to AWS Lambda:

Your AWS Lambda function’s code comprises a .rb file containing your function’s handler code, together with any additional dependencies (gems) your code depends on. To deploy this function code to Lambda, you use a deployment package.

## Creating .zip deployment packages with native libraries

To create a .zip deployment package containing gems with native extensions written in C (such as `nokogiri`) you can use a container to bundle your dependencies in an environment that is the same as the Lambda Ruby runtime environment. To complete these steps, you must have Docker installed on your build machine. To learn more about installing Docker, see [Install Docker Engine](https://docs.docker.com/engine/install/).

**To create a .zip deployment package in a Docker container**

1. Create Dockerfile with following:

```
FROM public.ecr.aws/sam/build-ruby3.2:latest-x86_64
RUN gem update bundler 
CMD "/bin/bash"
```

2. Inside the folder you created your `dockerfile` in, run the following command to create the Docker container.

```
docker build -t awsruby32 .
```

3. Run docker container with:

```
docker run --rm -it -v $PWD:/var/task -w /var/task awsruby32
```

4. Configure the bundle utility to install the gems specified in your `Gemfile` in a local `vendor/bundle` directory and install your dependencies.

```
bash-4.2# bundle config set --local path 'vendor/bundle' && bundle install --without development test
```

5. Create the .zip deployment package with your function code and its dependencies. 

```
bash-4.2# zip -r deployment_package.zip lambda_function.rb src vendor
```

6. Exit the container and return to your local project directory.

```
bash-4.2# exit
```

7. To restore bundle locally run:

```
rm -rf .bundle
```

## Creating and updating Ruby Lambda functions using .zip files using the console

To create a new function, you must first create the function in the console, then upload your .zip archive. 

If your .zip file is less than 50MB, you can create or update a function by uploading the file directly from your local machine. For .zip files greater than 50MB, you must upload your package to an Amazon S3 bucket first. This project's .zip file is less than 50MB.

1. Open the [Functions page](https://console.aws.amazon.com/lambda/home#/functions) of the Lambda console and choose **Create Function**.
2. Choose **Author from scratch**.
3. Under **Basic information**, do the following:
    a. For **Function name**, enter the name for your function.
    b. For **Runtime**, select the runtime you want to use. This project is using **Ruby 3.2**.
    c. (Optional) For **Architecture**, choose the instruction set architecture for your function. The default    architecture is x86_64. Ensure that the .zip deployment package for your function is compatible with the instruction set architecture you select.
4. (Optional) Under **Permissions**, expand **Change default execution role**. You can create a new **Execution role** or use an existing one.
5. Choose **Create function**. Lambda creates a basic 'Hello world' function using your chosen runtime.
```
require 'json'

def lambda_handler(event:, context:)
    # TODO implement
    { statusCode: 200, body: JSON.generate('Hello from Lambda!') }
end
```
The Lambda function handler is the method in your function code that processes events. When your function is invoked, Lambda runs the handler method. Your function runs until the handler returns a response, exits, or times out.

6. Select the **Configuration** tab. 
    a. In the **General configuration** tab, set **Timeout** to 10 sec.
    b. In the **Environment variables** tab, set keys: API_KEY, BUCKET and CLOUDFRONT_DISTRIBUTION.


**To upload a .zip archive from your local machine (console)**
1. In the [Functions page](https://console.aws.amazon.com/lambda/home#/functions) of the Lambda console, choose the function you want to upload the .zip file for.
2. Select the **Code** tab.
3. In the **Code source** pane, choose **Upload from**.
4. Choose **.zip file**.
5. To upload the .zip file, do the following:
    a. Select **Upload**, then select your .zip file in the file chooser.
    b. Choose **Open**.
    c. Choose **Save**.


## Set Up Scheduled Execution with Amazon EventBridge (CloudWatch Events)

If you want your Lambda function to run periodically, you can set up a CloudWatch Events Rule to trigger it at a specified interval.

1. Open the [Functions page](https://console.aws.amazon.com/lambda/home#/functions) of the Lambda console.
2. Choose a function
3. Under **Function overview**, choose **Add trigger**.
4. Set the trigger type to **EventBridge (CloudWatch Events)**.
5. For **Rule**, choose **Create a new rule**. This project is using `cron(17 * ? * * *)`, so this cron expression triggers every day at 17 minutes past the hour, regardless of the hour, day of the month, month, day of the week, or year.
6. Configure the remaining options and choose **Add**.

For more information on expressions schedules, see [Schedule expressions using rate or cron](https://docs.aws.amazon.com/lambda/latest/dg/services-cloudwatchevents-expressions.html).
