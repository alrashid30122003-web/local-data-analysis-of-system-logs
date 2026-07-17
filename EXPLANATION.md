# Short Explanation Document

## Local Data Analysis of System Logs

**Student:** Mohammed Thayyab Yakub  
**GitHub username:** alrashid30122003-web

### Objective

The project demonstrates how Python can be used to extract, clean, summarize, and visualize Windows-style system-log data.

### Tools

- Python
- pandas
- matplotlib
- Windows Task Scheduler
- Git and GitHub

### Processing

The script reads a CSV file, validates required columns, converts timestamps, counts severity levels, finds the most frequent event sources, and groups events by date.

### Visualizations

1. Bar chart of log levels.
2. Horizontal bar chart of the ten most frequent sources.
3. Line chart showing daily event volume.

### Results

The included demonstration dataset contains 3,353 synthetic events from 8 sources. It includes 876 warnings, 314 errors, and 49 critical events.

### Automation

The project includes Windows batch and PowerShell scripts. These can be scheduled weekly through Windows Task Scheduler.

### Data Authenticity

The included CSV is synthetic and is clearly labelled as such. A real Event Viewer export should replace it when the assignment requires local machine logs.

### Conclusion

The assignment provides a reusable workflow for local system monitoring and produces an offline HTML report with charts.
