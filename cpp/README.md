# eos

This is a C++ library for cubic equation of states. This library provides templated classes for three types of cubic EoSs: van der Waals, Soave-Redlich-Kwong, and Peng-Robinson EoS. These are respectively defined as the following classes:

- `eos::VanDerWaalsEos`
- `eos::SoaveRedlichKwongEos`
- `eos::PengRobinsonEos`

Helper functions are defined to easily create an EoS object:

- `eos::make_van_der_waals_eos`
- `eos::make_soave_redlich_kwong_eos`
- `eos::make_peng_robinson_eos`

## Dependencies

[GNU Scientific Library (GSL)](https://www.gnu.org/software/gsl/) and [Googletest](https://github.com/google/googletest) is used for unit testing. While Googletest is included as a git submodule under the `third-party` directory, GSL must be provided by users. Using vcpkg, you can easily install and provide GSL with this library.

## Example of Usage

First, let's create an EoS:

```cpp
// Critical parameters of methane
const double pc = 4e6;      // Critical pressure [Pa]
const double tc = 190.6;    // Critical temperature [K]
const double omega = 0.008; // Acentric factor

// Creates EoS
const auto eos = eos::make_peng_robinson_eos(pc, tc, omega);
```

Z-factors and fugacity coefficients at a given pressure and temperature can be computed from a state:

```cpp
const double p = 3e6;    // Pressure [Pa]
const double t = 180.0;  // Temperature [K]
const auto state = eos.create_state(p, t);

// Computes z-factors at the pressure and temperature
// Please note that
// 1. You must provide a cubic equation solver,
// 2. There can be multile values of z-factors.
const auto z = state.zfactors(CubicEquationSolver{});

// Computes fugacity coefficient from a corresponding z-factor
std::vector<double> phi(z.size())
for (std::size_t = 0; i < z.size(); ++i) {
  phi[i] = state.fugacity_coeff(z[i]);
}
```

An example of `CubicEquationSolver` class can be found in `test/cubic_eos_test.cpp`.

Pressure at a given temperature and volume can be computed:

```cpp
const double t = 180.0;  // Temperature [K]
const double v = 0.001;  // Volume [m3]
const auto p = eos.pressure(t, v);

const std::size_t n = 100; // Number of samples
std::vector<double> v(n); // Array of volumes [m3]

// ... Initialize the array of volumes here ...

// Computes pressure along an isothermal line
const auto line = eos.create_line(t);
std::vector<double> p(n); // Array of pressures [Pa]
for (std::size_t i = 0; i < n; ++i) {
  p[i] = line.pressure(v[i]);
}
```