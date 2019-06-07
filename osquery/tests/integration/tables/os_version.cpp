/**
 *  Copyright (c) 2014-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under both the Apache 2.0 license (found in the
 *  LICENSE file in the root directory of this source tree) and the GPLv2 (found
 *  in the COPYING file in the root directory of this source tree).
 *  You may select, at your option, one of the above-listed licenses.
 */

// Sanity check integration test for os_version
// Spec file: specs/os_version.table

#include <osquery/tests/integration/tables/helper.h>

#include <osquery/logger.h>

namespace osquery {

class OsVersion : public IntegrationTableTest {};

TEST_F(OsVersion, test_sanity) {

  QueryData data = execute_query("select * from os_version");

  ASSERT_EQ(data.size(), 1ul);

  ValidatatioMap row_map = {
      {"name", NonEmptyString},
      {"version", NonEmptyString},
      {"major", NonNegativeInt},
      {"minor", NonNegativeInt},
#ifdef OSQUERY_WINDOWS
      {"patch", NormalType},
#else
      {"patch", NonNegativeInt},
#endif
#ifdef OSQUERY_LINUX
      {"build", NormalType},
#else
      {"build", NonEmptyString},
#endif
      {"platform", NonEmptyString},
      {"platform_like", NonEmptyString},
      {"codename", NormalType},
#ifdef OSQUERY_WINDOWS
      {"install_date", NonEmptyString},
#endif
  };
  validate_rows(data, row_map);
}

} // namespace osquery
