import com.google.gdata.client.spreadsheet.*;
import com.google.gdata.data.*;
import com.google.gdata.data.spreadsheet.*;
import com.google.gdata.util.*;

import processing.serial.*;

// Variables structures for google spreadsheet API
SpreadsheetService service;  //Holds link to all your spreadsheets
WorksheetEntry worksheet;  //Holds link to the sensor log spreadsheet
String uname = "g0gr33nuio@gmail.com";  //Your google account user name
String pwd = "G0Gr33nUIO";  //Your google account password
String spreadsheet_name = "go green database";  //Name of the spreadsheet you want to write data to.  Must match exactly, including case.
int spreadsheet_idx = 0; //Index for the "sensor log spreadsheet


//Variables for writing sensor data
Serial port;  // Create object from Serial class
int oldTime;  //timer variable
int reportingInterval = 2000;  //Number of miliiseconds between when sensor data is recorded

// Sends the data to the spreadsheet
void transmitData(float val) {
  String date = day() + "/" + month() + "/" + year();  //Build the current date
  String time = hour() + ":" + minute() + ":" + second(); //Build the current time
  try {
     //Create a new row with the name value pairs
     ListEntry newEntry = new ListEntry();    
     newEntry.getCustomElements().setValueLocal("date", date);
     newEntry.getCustomElements().setValueLocal("time", time);
     newEntry.getCustomElements().setValueLocal("reading", Float.toString(val));
     //Write it out to the google doc
     URL listFeedUrl = worksheet.getListFeedUrl();
     ListEntry insertedRow = service.insert(listFeedUrl, newEntry);
  } catch (Exception e) {
     println(e.getStackTrace());
  }  
}


void setup() {
  //Set up the serial port to read data
  //This code comes from example 11-8 of Getting Started with Processing
 // print(Serial.list());
  //String arduinoPort = Serial.list()[0];
  port = new Serial(this, "/dev/ttyACM0", 9600);
  port.bufferUntil('\n');
 // oldTime = millis();
  //Set up the google spreadsheet
  service = new SpreadsheetService("test");
  try {
     service.setUserCredentials(uname,  pwd);
     // Search for the spreadsheet named we're looking for
     // Note that according to the documentation you should be able to include the key in the URL, but I 
     // was unable to get this to work.  It looked like there was a bug report in.
     // As a work around, this code pulls a list of all the Spreadheets in your acocunt and searches for the
     // one with the matching name.  When it finds it, it breaks out of the loop and the index is set
     URL feedURL = new URL("http://spreadsheets.google.com/feeds/spreadsheets/private/full/");   
     SpreadsheetFeed feed = service.getFeed(feedURL, SpreadsheetFeed.class);
     for (SpreadsheetEntry entry: feed.getEntries()) {
       if (entry.getTitle().getPlainText().equals(spreadsheet_name) ) {
         break;
       } 
       spreadsheet_idx += 1;
     }   
     //Fetch the correct spreadsheet
     SpreadsheetEntry se = feed.getEntries().get(spreadsheet_idx); //Fetch the spreadsheet we want
     worksheet = se.getWorksheets().get(0);  //Fetch the first worksheet from that spreadsheet
     println("Found worksheet " + se.getTitle().getPlainText());
 
  } catch (Exception e) {
    println(e.toString());
  }
}

//boolean sent = false;
String buff = "";
//int NEWLINE = 10;
//String value;

void draw() { 
  while (port.available() > 0) {
    buff = port.readStringUntil('\n');
  }
  //print(buff);
  //print(1);
  if (buff != "") {
    if (buff.trim().equals("1")) {
      println("sending");
      transmitData(1);
    } else {
      println("other value " + buff);
    }
  }
  buff = "";
}

void keyPressed() {  
  if (key == '1') {
    transmitData(1);
    println("sending on keypress");
  }
}
