import 'package:rental_tax_port/models/landlord.dart';
import 'package:rental_tax_port/models/property.dart';

class TaxCalculationService {
  static const double _minimumTaxableIncome = 280000.0; // 280,000 KES per year
  static const double _residentTaxRate = 0.10; // 10% for resident landlords
  static const double _nonResidentTaxRate = 0.20; // 20% for non-resident landlords

  double calculateTax(Landlord landlord, List<Property> properties) {
    double annualRentalIncome = _calculateAnnualRentalIncome(properties);

    if (annualRentalIncome < _minimumTaxableIncome) {
      return 0.0; // No tax if below minimum taxable income
    }

    double taxRate = landlord.isResident ? _residentTaxRate : _nonResidentTaxRate;
    return annualRentalIncome * taxRate;
  }

  double _calculateAnnualRentalIncome(List<Property> properties) {
    return properties.fold(0.0, (sum, property) => sum + (property.monthlyRent * 12));
  }

  double calculateMonthlyTaxDeduction(Landlord landlord, Property property) {
    double annualRent = property.monthlyRent * 12;

    if (annualRent < _minimumTaxableIncome) {
      return 0.0; // No tax if below minimum taxable income
    }

    double taxRate = landlord.isResident ? _residentTaxRate : _nonResidentTaxRate;
    return property.monthlyRent * taxRate;
  }

  bool isEligibleForTaxation(Property property) {
    return property.monthlyRent * 12 >= _minimumTaxableIncome;
  }

  double getApplicableTaxRate(Landlord landlord) {
    return landlord.isResident ? _residentTaxRate : _nonResidentTaxRate;
  }
}