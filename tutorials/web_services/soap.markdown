It makes sense to put configuration in
environments/{development,test,production}/soap.yml.  This assumes
that we are connecting to a single SOAP server, which is pretty
typical.

Then a SoapSetting module can
YAML.load("config/#{Rails.env}/soap.yml") into a class variable.

You'll want to have an internal SoapRequest class.  This class can
encapsulate all of the logic that surrounds your specific SOAP server.
 For instance, one of our clients had their SOAP server designed such
that you could append the "WSDL=1" query string to any SOAP service
URL to get the WSDL.  We could then use a single setting for both the
WSDL and the URL for the particular SOAP service.

The SOAP Request class should also define a Response class.  There is
no need for anything outside the Request class to create Response
objects, so there is no need for a separate file.  Often, SOAP
services will follow some sort of convention across a server.  The
Response class is the place to encapsulate things like successful
responses, which might be buried somewhere in a <success>1</success>
somewhere.

For the most part, exceptions are best done elsewhere.  The only
exceptions that make sense in the the Request class are connectivity
or parsing errors.  Depending on how sophisticated your needs are,
these can be caught for logging and then re-raised.  It might also
make sense to wrap some common errors in your own exception classes.

Configuration of the SOAP client inside the Request class can pretty
much follow the savon.rb site.  It is a good idea to configure the
client once and then squirrel it away in a class variable for reuse by
other application requests.

As for the data itself, integrating Savon into a Rails app works best
when the SOAP services are somewhat RESTful.  If it is difficult to
map basic CRUD onto the SOAP services, then things are going to be
hard.  Assuming that basic CRUD is doable, there are things to be done
to make life easier.

The SOAP models should certainly define an errors object.  The easiest
way to do this is via an attr_accessor that get instantiated from an
AR::Errors object in intialize().  Sometimes it helps to define your
own Errors-like object, but I think this is overkill.  Other AR
attributes and methods should be present like new_record?, id,
to_params, etc.

The SOAP models should have an instance of the SOAP request object.
Upon initialization, the SOAP model can configured the SOAP request as
much as possible.  This usually means setting the SOAP request URL,
but other configuration might be necessary.

From there, it is a simple matter of defining the necessary AR methods
-- save, update, find, destroy, etc.  It is not necessary to define
all of these.  Only those methods that are needed by the app should be
defined.  These SOAP models do not need to mirror AR completely --
just sufficiently.

Methods like save should follow the same convention as Rails's save
method.  If the Response comes back response.ok? == false, then the
SOAP model should set the errors object accordingly.  Whether or not
those errors go on base or on particular attributes mostly depends on
the level of sophistication required.  Often sticking with base is
fine.

On a somewhat advanced note, it is possible to hook these calls into
the AR callback chain.  For instance, if you have a Post model, it is
possible to add an after_save callback to Post to make a SOAP save to
another interested service.  It is generally best to do such a thing
in an after_save to allow normal AR processing to take place.  When
things go wrong, however, exceptions need to be thrown -- returning
false from an after_save is not sufficient.  This requires changing
controller actions to handle exceptions (boilerplate Rails checks
return values).