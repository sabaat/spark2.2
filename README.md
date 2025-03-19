## Prerequisites

Before you begin, please ensure you have the following installed on your system:

- [Docker](https://docs.docker.com/get-docker/)
- [Git](https://git-scm.com/downloads)

## Getting Started

### 1. Clone the Repository

Students can clone the repository using the following command:

```bash
git clone https://github.com/sabaat/spark2.2.git
cd spark2.2
```

### 2. Build the Docker Image
In the project root (where the Dockerfile is located), run:

```bash
docker build -t my-spark-project .
```

### 3. Run the Docker Container
After building the image, run the container:

```bash
docker run -it my-spark-project
```

This will start the container and drop you into a bash shell inside the Docker environment.

### Additional Information
## Project Files:
Your project files are located in the /opt/spark-homework-udf directory within the container.
## Spark Usage:
Use the installed Spark instance by running commands like spark-shell inside the container.


## Run the following command to get essential tools for building spark
```bash
apt-get update && apt-get install build-essential
```
## Building Spark

Once you have the pulled the code, run `make compile`. The first time you run this command, it should take a while -- `sbt` will download all the dependencies and compile all the code in Spark (there's quite a bit of code). Once the initial assembly commands finish, you can start your project! (Future builds should not take this long -- `sbt` is smart enough to only recompile the changed files, unless you run `make clean`, which will remove all compiled class files.)

# Your Task

## Disk hash-partitioning

We have provided you skeleton code for `DiskHashedRelation.scala`. This file has 4 important things:
* `trait DiskHashedRelation` defines the DiskHashedRelation interface
* `class GeneralDiskHashedRelation` is our implementation of the `DiskedHashedRelation` trait
* `class DiskPartition` represents a single partition on disk
* `object DiskHashedRelation` can be thought of as an object factory that constructs `GeneralDiskHashedRelation`s

### Task #1: Implementing `DiskPartition` and `GeneralDiskHashedRelation`

First, you will need to implement the `insert`, `closeInput`, and `getData` methods in `DiskPartition` for this part. For the former two, the docstrings should provide a comprehensive description of what you must implement. The caveat with `getData` is that you *cannot* read the whole partition into memory in once. The reason we are enforcing this restriction is that there is no good way to enforce freeing memory in the JVM, and as you transform data to different forms, there would be multiple copies lying around. As such, having multiple copies of a whole partition would cause things to be spilled to disk and would make us all sad. Instead, you should stream *one block* into memory at a time.

At this point, you should be passing the tests in `DiskPartitionSuite.scala`.

### Task #2: Implementing `object DiskHashedRelation`

Your task in this portion will be to implement phase 1 of external hashing -- using a coarse-grained hash function to stream an input into multiple partition relations on disk. For our purposes, the `hashCode` method that every object has is sufficient for generating a hash value, and taking the modulo by the number of the partitions is an acceptable hash function. 

At this point, you should be passing all the tests in `DiskHashedRelationSuite.scala`.

## In-Memory UDF Caching

In this section, we will be dealing with `case class CacheProject` in `basicOperators.scala`. You might notice that there are only 4 lines of code in this class and, more importantly, no `// IMPLEMENT ME`s. You don't actually have to write any code here. However, if you trace the function call in [line 66](https://github.com/ariyam/cs143_spark_hw/blob/master/sql/core/src/main/scala/org/apache/spark/sql/execution/basicOperators.scala#L66), you will find that there are two parts of this stack you must implement in order to have a functional in-memory UDF implementation. 

### Task #3: Implementing `CS143Utils` methods

For this task, you will need to implement `getUdfFromExpressions` and the `Iterator` methods in `CachingIteratorGenerator#apply`. Please read the docstrings -- especially for `apply` -- closely before getting started.

After implementing these methods, you should be passing the tests in `CS143UtilsSuite.scala`.

Hint: Think carefully about why these methods might be a part of the Utils

## Disk-Partitioned UDF Caching

Now comes the moment of truth! We've implemented disk-based hash partitioning, and we've implemented in-memory UDF caching -- what is sometimes called [memoization](http://en.wikipedia.org/wiki/Memoization). Memoization is very powerful tool in many contexts, but here in databases-land, we deal with larger amounts of data than memoization can handle. If we have more unique values than can fit in an in-memory cache, our performance will rapidly degrade. 
Thus, we fall back to the time-honored databases tradition of divide-and-conquer. If our data does not fit in memory, then we can partition it to disk once, read one partition in at a time (think about why this works (hint: rendezvous!)), and perform UDF caching, evaluating one partition at a time. 

### Task 4: Implementing `PartitionProject`

This final task requires that you fill in the implementation of `PartitionProject`. All the code that you will need to write is in the `generateIterator` method. Think carefully about how you need to organize your implementation. You should *not* be buffering all the data in memory or anything similar to that. 

At this point, you should be passing ***all*** given tests.

### Thought Exercise 

There is no code you have to write here, but for your own edification, spend some time thinking about the following question:

One of Spark's main selling points is that it is "in-memory". What they mean is the following: When you string a number of Hadoop (or any other MapReduce framework) jobs together, Hadoop will write the results of each phase to disk and read them in again which is very expensive; Spark, on the other hand, maintains its data in memory. However, if our assumption is that if our data doesn't fit in memory, then why does Spark SQL not ship with disk-based implementation of these operators already? In this respect, why is Spark different from the "traditional" parallel relational databases we learn about in class?  There is no right answer to this question! 

## Testing

We have provided you some sample tests in `DiskPartitionSuite.scala`, `DiskHasedRelationSuite.scala`, `CS143UtilsSuite.scala` and `ProjectSuite.scala`. These tests can guide you as you complete this project. However, keep in mind that they are *not* comprehensive, and you are well advised to write your own tests to catch bugs. Hopefully, you can use these tests as models to generate your own tests. 

In order to run our tests, we have provided a simple Makefile. In order to run the tests for task 1, run `make t1`. Correspondingly for task, run `make t2`, and the same for all other tests. `make all` will run all the tests. 


**Good luck!**

