unit untAdminSystem;

interface

uses
  Windows;

type
  TAdmin = Class(TObject)
  Private
    Admins      :Array[0..99] Of String;
  Public
    Procedure LoginAdmin(szUser: String);
    Procedure LogoutAdmin(szUser: String);
    Procedure ClearAdmin;

    Function AdminLoggedIn(szUser: String): Boolean;
  End;

var
  Admin :TAdmin;

implementation

Function TAdmin.AdminLoggedIn(szUser: String): Boolean;
Var
  iLoop :Integer;
Begin
  Result := False;
  For iLoop := 0 To 99 Do
    If Admins[iLoop] = szUser Then
    Begin
      Result := True;
      Break;
    End;
End;

Procedure TAdmin.ClearAdmin;
Var
  iLoop :Integer;
Begin
  For iLoop := 0 To 99 Do
    Admins[iLoop] := '';
End;

Procedure TAdmin.LogoutAdmin(szUser: String);
Var
  iLoop :Integer;
Begin
  If Not AdminLoggedIn(szUser) Then Exit;
  For iLoop := 0 To 99 Do
    If Admins[iLoop] = szUser Then
    Begin
      Admins[iLoop] := '';
      Break;
    End;
End;

Procedure TAdmin.LoginAdmin(szUser: String);
Var
  iLoop :Integer;
Begin
  If AdminLoggedIn(szUser) Then Exit;
  For iLoop := 0 To 99 Do
    If Admins[iLoop] = '' Then
    Begin
      Admins[iLoop] := szUser;
      Break;
    End;
End;

end.
 