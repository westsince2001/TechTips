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
  Age int32
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

There are *3* ways to drop one table:

1. db.DropTable(&Student{})
2. db.DropTable("students")
3. db.DropTableIfExists(&Student{}, "students")

#### Make Index

Now we could use `AddIndex()` and `AddUniqueIndex()` to add indexes.

* db.Model(&Student{}).AddIndex("idx_name", "name")
* db.Model(&Student{}).AddUniqueIndex("unique_idx_name", "name")

#### Add Foreign Key

Through `AddForeignKey()` we add foreign key to one column. The description of parameters is listed below:

1. 1st param: foreign key field
2. 2nd param: destination table(id)
3. 3rd param: ONDELETE
4. 4th param: ONUPDATE

* db.Model(&Student{}).AddForeignKey("city_id", "cities(id)", "RESTRICT", "RESTRICT")

#### Create

On Create, we need one instance of this struct. For example:

```golang
  Jack := &Student{
    Name: "Jack",
    Age: 18,
  }
```

* db.Create(&Jack)

Before we create `Jack`, we would like to first check if it's a new record via:

* db.NewRecord(&Jack) 

#### Retrieve

Query always makes up the most dynamic database operations.

We coud get data throught helper function: `Find()`, `First()`, `Last()`, but on `Where()` condition, we can do below:

* db.Where(&Student{Name:"Jack", Age:18}).Find(&who)
* db.Where(map[string]interface{"name":"Jack","age":18}).Find(&who)
* db.Where([]int32{18,19,20}).Find(&who)

but I didn't figure how slice works in where condition.

On the other side, we could use inline condiditon for querying:

* db.Find(&who, "name = ?", "Jack")
* db.Find(&who, "name <> ? AND age > ?", "Jack", "20")
* db.Find(&who, Student{Name:"Jack"})
* db.Find(&who, map[string]interface{"name":"Jack"})

Or:

* db.Find(&who, "name = ?", "Jack").Or("age = ?", "18")

assuming `who` is the instance of data structure `Student`

#### Update

#### Delete

### Advanced Usage
