Overview
==========
gorm is one of the most popular golang ORM now. We could operate our database more convienent and effciently with gorm.

Here is the [Homepage](github.com/jinzhu/gorm) and [GoDoc](https://godoc.org/github.com/jinzhu/gorm) of gorm.

### Basic Usage

#### Connection to database

* import the jinzhu/gorm package:
  * import "github.com/jinzhu/gorm"
* import the mysql driver:
  * import _ "github.com/jinzhu/gorm/dialects/mysql"
* connection to database
  * db, err := gorm.Open("mysql", "root:root@tcp(mysql.mycluster:3306)/ormtest?charset=utf8&parsetTime=True&loc=Local")
  
#### Create Table

At first, we indeed need one struct refering to the table will be used. For example:

```golang
type Student struct {
  gorm.Model
  Name string `gorm:unique`
  Number int32 `gorm:AUTO_INCREMENT`
}
```

* db.CreateTable(&Student{})
* db.Set("gorm:table_options","ENGINE=InnoDB").CreateTable(&Student{})

#### Set Table's Name

In default, table's name will be made according to our struct name:

* Student -> student
* AirCraft -> air_craft

We could set table's name #before creating table# like below: 

* gorm.DefaultTableNameHandler = func(db *gorm.DB, defaultTableName string) string {
    return "mush_" + defaultTableName
  }

then the name upper will be looks like:

* Student -> mush_student
* AirCraft -> mush_air_craft

or we can define another function `TableName()`:

* (Student)TableName() string {
    return "students"
  }


#### Drop Table

There are #4# ways to drop one table:

1. db.DropTable(&Student{})
2. db.DropTable("students")
3. db.DropTableIfExists(&Student{}, "students")


#### NewRecord and Create
Then, we need one instance of this struct. For example:

```golang
  Jack := new(Student)
```

### Advanced Usage
