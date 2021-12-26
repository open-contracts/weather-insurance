
import opencontracts
import os, h5py
from earthdata import Auth, DataGranules, DataCollections, Accessor
from datetime import datetime

with opencontracts.enclave_backend() as enclave:
  lat, lon = enclave.user_input('Latitude, Longitude (+-70, +-180):').split(',')
  lat, lon = int(lat), int(lon)
  yr, mo = enclave.user_input('Year-Month (YY-MM)').split('-')
  yr, mo = int(yr), int(mo)
  threshold = int(enclave.user_input('Threshold:'))
  policyID = enclave.keccak(lat, lon, yr, mo, threshold,
                            types=('int256', 'int256', 'uint16', 'uint8', 'uint256'))
  enclave.print(f'You are about to settle the insurance with policyID {"0x"+policyID.hex()}.')
  
  os.environ["CMR_USERNAME"] = enclave.user_input('Username for NASA Earthdata API:')
  os.environ["CMR_PASSWORD"] = enclave.user_input('Password for NASA Earthdata API:')
  enclave.expect_delay(120, 'Downloading NASA data...')
  auth = Auth()
  auth.login(strategy='environment')
  collection = DataCollections(auth).keyword('GPM_3GPROFGPMGMI').get(1)[0]['meta']
  granules = DataGranules(auth).concept_id(collection['concept-id'])
  granules = granules.temporal(date_from=datetime(2000 + yr, mo, 1).isoformat(),
                               date_to=datetime(2000 + yr, mo+1, 1).isoformat()).get()
  access = Accessor(auth)
  access.get(granules, './dl')
  f = h5py.File('./dl/'+os.listdir('./dl')[0],'r')
  data = f['Grid']['surfacePrecipitation'][:, :]
  data[data<0] = float('nan')
  precipitation = data[round((lon+180)/360*1440), round((lat+70)/140*720)] * 1000
  assert precipitation == precipitation, "Precipitation data is NaN, likely wrong coordinates."
  
  damage_occured = precipitation < threshold
  msg = f'Validated Precipitation of {precipitation} on {yr}-{mo} at ({lat},{lon}), '
  msg += f'which means the damage did{" not"*(not damage_occured)} occur.'
  enclave.print(msg)
  beneficiary = enclave.user_input('Address of Beneficiary:')
  enclave.submit(beneficiary, policyID, damage_occured, types=('address', 'bytes32', 'bool'), function_name='settle')
