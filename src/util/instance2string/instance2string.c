#include "cmpidt.h"
#include "cmpift.h"
#include "cmpimacs.h"
#include "OSBase_Common.h"
#include "cmpiOSBase_Common.h"

#define _MAXINSTANCELENGTH 1024

/*
 * instance2string
 */
int Linux_NFSv4_instance2string (const CMPIInstance * instance, char ** buffer)
{
   CMPIData data;			/* General purpose CIM data storage for CIM property values */
   char string[_MAXINSTANCELENGTH];	/* General purpose string buffer for formatting values */
   char * str;				/* General purpose string pointer */

   /* Create a text buffer to hold the new config file entry */
   *buffer = malloc(_MAXINSTANCELENGTH);
   strcpy(*buffer, "");

   /* First write out any comments associated with this instance */
   data = CMGetProperty(instance, "Description", NULL);
   if (!CMIsNullValue(data)) {
      str = CMGetCharPtr(data.value.string);
      if (str[0] != '#') strcat(*buffer, "# "); /* Make sure the description becomes a comment */
      strcat(strcat(*buffer, str), "\n");
   }

   /* Write out the config file entry values for this instance */
   data = CMGetProperty(instance, "Directory", NULL);
   if (!CMIsNullValue(data)) {
      strcat(strcat(*buffer, CMGetCharPtr(data.value.string)), "\t");
   } else {
      /* If the Directory attribute is not set then get it from the SettingID instead */
      data = CMGetProperty(instance, "SettingID", NULL);
      strcat(strcat(*buffer, CMGetCharPtr(data.value.string)), "\t");
   }
   
   strcat(*buffer, "(");

   data = CMGetProperty(instance, "PseudoPath", NULL);
   if (!CMIsNullValue(data)) {
      strcat(strcat(strcat(*buffer, "pseudo="), CMGetCharPtr(data.value.string)), ",");

      data = CMGetProperty(instance, "Permission", NULL);
      if (!CMIsNullValue(data)) {
         str = CMGetCharPtr(data.value.string);
         if (strcmp(str,"rw") && strcmp(str,"ro")) {
            _OSBASE_TRACE(1,("instance2string() : Invalid property value: Permission=%s",str));
            return 0;
         }
         strcat(strcat(*buffer, CMGetCharPtr(data.value.string)), ",");
      }

      strcat(*buffer, "sec=");
      
      data = CMGetProperty(instance, "Security_none", NULL);
      if (!CMIsNullValue(data) && data.value.boolean) strcat(*buffer, "none:"); 

      data = CMGetProperty(instance, "Security_sys", NULL);
      if (!CMIsNullValue(data) && data.value.boolean) strcat(*buffer, "sys:");

      data = CMGetProperty(instance, "Security_dh", NULL);
      if (!CMIsNullValue(data) && data.value.boolean) strcat(*buffer, "dh:");

      data = CMGetProperty(instance, "Security_krb5", NULL);
      if (!CMIsNullValue(data) && data.value.boolean) strcat(*buffer, "krb5:");

      data = CMGetProperty(instance, "Security_krb5i", NULL);
      if (!CMIsNullValue(data) && data.value.boolean) strcat(*buffer, "krb5i:");

      data = CMGetProperty(instance, "Security_krb5p", NULL);
      if (!CMIsNullValue(data) && data.value.boolean) strcat(*buffer, "krb5p:");

      data = CMGetProperty(instance, "Security_spkm3", NULL);
      if (!CMIsNullValue(data) && data.value.boolean) strcat(*buffer, "spkm3:");

      data = CMGetProperty(instance, "Security_spkm3i", NULL);
      if (!CMIsNullValue(data) && data.value.boolean) strcat(*buffer, "spkm3i:");

      data = CMGetProperty(instance, "Security_spkm3p", NULL);
      if (!CMIsNullValue(data) && data.value.boolean) strcat(*buffer, "spkm3p:");

      data = CMGetProperty(instance, "Security_lkey", NULL);
      if (!CMIsNullValue(data) && data.value.boolean) strcat(*buffer, "lkey:");

      data = CMGetProperty(instance, "Security_lkeyi", NULL);
      if (!CMIsNullValue(data) && data.value.boolean) strcat(*buffer, "lkeyi:");

      data = CMGetProperty(instance, "Security_lkeyp", NULL);
      if (!CMIsNullValue(data) && data.value.boolean) strcat(*buffer, "lkeyp:");

      if ((*buffer)[strlen(*buffer)-1] == '=') {
	 /* No security options, so remove "sec=" */
         (*buffer)[strlen(*buffer)-1] = '\0';
         (*buffer)[strlen(*buffer)-1] = '\0';
         (*buffer)[strlen(*buffer)-1] = '\0';
	 (*buffer)[strlen(*buffer)-1] = '\0';
      }
   }

   if ((*buffer)[strlen(*buffer)-1] == ':') (*buffer)[strlen(*buffer)-1] = '\0'; /* remove last colon */
   if ((*buffer)[strlen(*buffer)-1] == ',') (*buffer)[strlen(*buffer)-1] = '\0'; /* remove last comma */
   strcat(*buffer, ")\n");

   _OSBASE_TRACE(1,("instance2string() : New instance entry is\nSTART-->%s<--END", *buffer));
   return 1;
}

