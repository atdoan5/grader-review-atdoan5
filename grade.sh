CPATH='.:lib/hamcrest-core-1.3.jar:lib/junit-4.13.2.jar'

rm -rf student-submission
rm -rf grading-area

mkdir grading-area

git clone $1 student-submission
echo 'Finished cloning'


# Draw a picture/take notes on the directory structure that's set up after
# getting to this point

# Then, add here code to compile and run, and do any post-processing of the
# tests

if [ -f "student-submission/ListExamples.java" ]; then
    echo "File found!"
else 
    echo "ListExamples.java not found!"
    exit 1
fi

# jars
cp -r lib grading-area
# ListExamples
cp student-submission/ListExamples.java grading-area/
# TestListExamples
cp TestListExamples.java grading-area/

cd grading-area/
javac -cp $CPATH *.java

if [ $? -ne 0 ]; then
    echo "Compile error!"
    exit 1
else 
    echo "Compiled successfully!"
fi 

java -cp $CPATH org.junit.runner.JUnitCore TestListExamples > junit-output.txt


# Read the JUnit output from the file
junit_output=$(cat junit-output.txt)

if grep -q "OK (.* tests)" <<< "$junit_output"; then
    num_tests=$(echo "$junit_output" | grep -o "OK ([0-9]* tests)" | cut -d'(' -f2 | cut -d' ' -f1)
    num_passed_tests=$(echo "$junit_output" | grep -o "OK ([0-9]* tests)" | cut -d'(' -f2 | cut -d' ' -f1)
    score="$num_passed_tests/$num_tests"
else
    # Count the number of tests and failures
    num_tests=$(echo "$junit_output" | grep -o "Tests run: [0-9]*" | cut -d' ' -f3)
    num_failures=$(echo "$junit_output" | grep -o "Failures: [0-9]*" | cut -d' ' -f2)

    # Calculate the score
    passed_tests=$((num_tests - num_failures))
    score="$passed_tests/$num_tests"
fi

# Output the score
echo "Score: $score"
