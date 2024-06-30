call sys.check();
call sys.drop('auth.validate_email');

create function auth.validate_email(
    _email text
)
returns boolean
language plpgsql
immutable
parallel safe
as
$$
declare
    _regex_rfc822 constant text 
        = '^([^\x00-\x20\x22\x28\x29\x2c\x2e\x3a-\x3c\x3e\x40\x5b-\x5d\x7f-\xff]+|\x22([^\x0d\x22\x5c\x80-\xff]|\x5c[\x00-\x7f])*\x22)(\x2e([^\x00-\x20\x22\x28\x29\x2c\x2e\x3a-\x3c\x3e\x40\x5b-\x5d\x7f-\xff]+|\x22([^\x0d\x22\x5c\x80-\xff]|\x5c[\x00-\x7f])*\x22))*\x40([^\x00-\x20\x22\x28\x29\x2c\x2e\x3a-\x3c\x3e\x40\x5b-\x5d\x7f-\xff]+|\x5b([^\x0d\x5b-\x5d\x80-\xff]|\x5c[\x00-\x7f])*\x5d)(\x2e([^\x00-\x20\x22\x28\x29\x2c\x2e\x3a-\x3c\x3e\x40\x5b-\x5d\x7f-\xff]+|\x5b([^\x0d\x5b-\x5d\x80-\xff]|\x5c[\x00-\x7f])*\x5d))*$';
    _regex_non_ascii constant text 
        = '[^\x00-\x7F]+';
begin 
    if (not _email ~ _regex_non_ascii and _email ~ _regex_rfc822) then
        return true;
    else
        return false;
    end if;
end
$$;

call sys.annotate('auth.validate_email', 'Validates email by RFC822 standard.');

create or replace procedure test.auth_validate_emails()
language plpgsql as
$$
declare
    _record record;
begin
    for _record in (select * from (values
        ('ValidDomain', 'email@example.com', TRUE),
        ('WebIsDomain', 'email@example.web', TRUE),
        ('DotInAddress', 'firstname.lastname@example.com', TRUE),
        ('DotInSubdomain', 'email@subdomain.example.com', TRUE),
        ('PlusInAddress', 'firstname+lastname@example.com', TRUE),
        ('DomainIsValidIPAddress', 'email@123.123.123.123', TRUE),
        ('DomainIsValidIPAddressInBrackets', 'email@[123.123.123.123]', TRUE),
        ('QuotedAddress', '"email"@example.com', TRUE),
        ('DigitsInAddress', '1234567890@example.com', TRUE),
        ('DashInDomain', 'email@example-one.com', TRUE),
        ('UnderscoreAddress', '_______@example.com', TRUE),
        ('DashInAddress', 'firstname-lastname@example.com', TRUE),
        ('ListOfAddresses1', 'email1@example.com, email2@example.com', FALSE),
        ('ListOfAddresses2', 'email1@example.com; email2@example.com', FALSE),
        ('ListOfAddresses3', 'email1@example.com email2@example.com', FALSE),
        ('EmptyString', '', FALSE),
        ('MissingAtAndDomain', 'plainaddress', FALSE),
        ('Garbage', '#@%^%#$@#$@#.com', FALSE),
        ('MisingAddress', '@example.com', FALSE),
        ('EncodedHtml', 'Joe Smith <email@example.com>', FALSE),
        ('MissingAt', 'email.example.com', FALSE),
        ('TwoAtSigns', 'email@example@example.com', FALSE),
        ('LeadingDot', '.email@example.com', FALSE),
        ('TrailingDotInAddress', 'email@example.com.', FALSE),
        ('MultipleDotsAddress', 'email..email@example.com', FALSE),
        ('UnicodeInAddress', 'あいうえお@example.com', FALSE),
        ('TextAfterEmail', 'email@example.com (Joe Smi)', FALSE),
        ('MissingTopLevelDomain', 'email@example', TRUE),
        ('LeadingDashDomain', 'email@-example.com', TRUE),
        ('MultipleDotsInDomain', 'email@example..com', FALSE),
        ('NotRight1', '"(),:;<>[\]@example.com', FALSE),
        ('MultipleQuotes', 'just"not"right@example.com', FALSE),
        ('NotAllowed', 'this\isreally"not\allowed@example.com', FALSE),
        ('VeryVeryUnusual1', 'very."(),:;<>[]".VERY."very@\"very".unusual@strange.example.com', TRUE),
        ('VeryVeryUnusual2', 'very."(),:;<>[]".VERY."very"very".unusual@strange.example.com', FALSE),
        ('MuchMoreUnusal', 'much."more\ unusual"@example.com', TRUE),
        ('VeryUnusual', 'very.unusual."@".unusual.com@example.com', TRUE)) t (id, test, expected)
    ) loop
        assert auth.validate_email(_record.test) = _record.expected, 'Test ' || _record.id || ' failed.';
    end loop;
end
$$;
call test.auth_validate_emails();
