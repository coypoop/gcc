------------------------------------------------------------------------------
--                                                                          --
--                         GNAT RUN-TIME COMPONENTS                         --
--                                                                          --
--                  ADA.NUMERICS.BIG_NUMBERS.BIG_INTEGERS                   --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
-- This specification is derived from the Ada Reference Manual for use with --
-- GNAT.  In accordance with the copyright of that document, you can freely --
-- copy and modify this specification,  provided that if you redistribute a --
-- modified version,  any changes that you have made are clearly indicated. --
--                                                                          --
------------------------------------------------------------------------------

pragma Ada_2020;

with Ada.Strings.Text_Output; use Ada.Strings.Text_Output;

private with Ada.Finalization;
private with System;

package Ada.Numerics.Big_Numbers.Big_Integers
  with Preelaborate
is
   type Big_Integer is private
     with Integer_Literal => From_String,
          Put_Image       => Put_Image;

   function Is_Valid (Arg : Big_Integer) return Boolean
     with Convention => Intrinsic;

   subtype Valid_Big_Integer is Big_Integer
     with Dynamic_Predicate => Is_Valid (Valid_Big_Integer),
          Predicate_Failure => raise Program_Error;

   function "=" (L, R : Valid_Big_Integer) return Boolean;

   function "<" (L, R : Valid_Big_Integer) return Boolean;

   function "<=" (L, R : Valid_Big_Integer) return Boolean;

   function ">" (L, R : Valid_Big_Integer) return Boolean;

   function ">=" (L, R : Valid_Big_Integer) return Boolean;

   function To_Big_Integer (Arg : Integer) return Valid_Big_Integer;

   subtype Big_Positive is Big_Integer
     with Dynamic_Predicate =>
            (if Is_Valid (Big_Positive)
             then Big_Positive > To_Big_Integer (0)),
          Predicate_Failure => (raise Constraint_Error);

   subtype Big_Natural is Big_Integer
     with Dynamic_Predicate =>
            (if Is_Valid (Big_Natural)
             then Big_Natural >= To_Big_Integer (0)),
          Predicate_Failure => (raise Constraint_Error);

   function In_Range (Arg, Low, High : Big_Integer) return Boolean is
     ((Low <= Arg) and (Arg <= High));

   function To_Integer (Arg : Big_Integer) return Integer
     with Pre => In_Range (Arg,
                           Low  => To_Big_Integer (Integer'First),
                           High => To_Big_Integer (Integer'Last))
                  or else (raise Constraint_Error);

   generic
      type Int is range <>;
   package Signed_Conversions is

      function To_Big_Integer (Arg : Int) return Valid_Big_Integer;

      function From_Big_Integer (Arg : Big_Integer) return Int
        with Pre => In_Range (Arg,
                              Low  => To_Big_Integer (Int'First),
                              High => To_Big_Integer (Int'Last))
                     or else (raise Constraint_Error);

   end Signed_Conversions;

   generic
      type Int is mod <>;
   package Unsigned_Conversions is

      function To_Big_Integer (Arg : Int) return Valid_Big_Integer;

      function From_Big_Integer (Arg : Big_Integer) return Int
        with Pre => In_Range (Arg,
                              Low  => To_Big_Integer (Int'First),
                              High => To_Big_Integer (Int'Last))
                     or else (raise Constraint_Error);

   end Unsigned_Conversions;

   function To_String (Arg   : Valid_Big_Integer;
                       Width : Field := 0;
                       Base  : Number_Base := 10) return String
     with Post => To_String'Result'First = 1;

   function From_String (Arg : String) return Big_Integer;

   procedure Put_Image (S : in out Sink'Class; V : Big_Integer);

   function "+" (L : Valid_Big_Integer) return Valid_Big_Integer;

   function "-" (L : Valid_Big_Integer) return Valid_Big_Integer;

   function "abs" (L : Valid_Big_Integer) return Valid_Big_Integer;

   function "+" (L, R : Valid_Big_Integer) return Valid_Big_Integer;

   function "-" (L, R : Valid_Big_Integer) return Valid_Big_Integer;

   function "*" (L, R : Valid_Big_Integer) return Valid_Big_Integer;

   function "/" (L, R : Valid_Big_Integer) return Valid_Big_Integer;

   function "mod" (L, R : Valid_Big_Integer) return Valid_Big_Integer;

   function "rem" (L, R : Valid_Big_Integer) return Valid_Big_Integer;

   function "**" (L : Valid_Big_Integer; R : Natural) return Valid_Big_Integer;

   function Min (L, R : Valid_Big_Integer) return Valid_Big_Integer;

   function Max (L, R : Valid_Big_Integer) return Valid_Big_Integer;

   function Greatest_Common_Divisor
     (L, R : Valid_Big_Integer) return Big_Positive
     with Pre => (L /= To_Big_Integer (0) and R /= To_Big_Integer (0))
       or else (raise Constraint_Error);

private

   type Controlled_Bignum is new Ada.Finalization.Controlled with record
      C : System.Address := System.Null_Address;
   end record;

   procedure Adjust   (This : in out Controlled_Bignum);
   procedure Finalize (This : in out Controlled_Bignum);

   type Big_Integer is record
      Value : Controlled_Bignum;
   end record;

end Ada.Numerics.Big_Numbers.Big_Integers;
