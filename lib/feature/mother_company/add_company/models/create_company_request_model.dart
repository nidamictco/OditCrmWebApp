class CreateCompanyRequest {
  final String companyName;

  final String companyCategory;

  final String contactPerson;

  final String mobile;

  final String password;

  final String address;

  final String logoUrl;

  const CreateCompanyRequest({
    required this.companyName,
    required this.companyCategory,
    required this.contactPerson,
    required this.mobile,
    required this.password,
    required this.address,
    required this.logoUrl,
  });
}