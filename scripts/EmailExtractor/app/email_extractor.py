import os
import ConfigParser
import traceback

class email_extractor():
    
    def __init__(self):
        
        # SET ENVIRONMENT VARIABLES
        self.CONFPATH = "../conf/"
        self.PROPSFILE = self.CONFPATH + "properties.ini"
        
        # config object that is queried for properties file info
        self.config = self.prep_config_object(self.PROPSFILE)
        
        # set the values of these variables to the contents in the props file
        self.website = self.config.get("properties", "website")
        self.output_filename = self.config.get("properties", "output_filename")
    
    def prep_config_object(self, path):
        config = ConfigParser.ConfigParser()
        config.readfp(open(path))
        return config
    
    def extract(self):
        try:
            os.system("wget -q -O - " + self.website + " | grep -E -o '\\b[a-zA-Z0-9.-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z0-9.-]+\\b' > " + self.output_filename)
        except:
            print "Uh Oh! There was an error!"
            traceback.print_exc()

if __name__ == "__main__":
    print "--------------------------------------------"
    print "Starting email extractor program"
    print "--------------------------------------------"
    
    emex = email_extractor()
    emex.extract()
    
    print ""
    
    print "--------------------------------------------"
    print "Email extractor program was successful"
    print "--------------------------------------------"