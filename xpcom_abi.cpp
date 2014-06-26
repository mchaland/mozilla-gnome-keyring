#include <stdio.h>
#include <stdint.h>

#if HAVE_MOZ_BUG_956507
#include "mozilla/Char16.h"
#endif

#include "nsIXULRuntime.h"
#include "nsServiceManagerUtils.h"
#include "nsStringAPI.h"
#include "nsXPCOM.h"
#include "nsXPCOMCIDInternal.h"

/**
 * Print the XPCOM ABI string, e.g. Linux_x86-gcc3
 *
 * See:
 * https://developer.mozilla.org/en/Bundles#Platform-specific_files
 * https://developer.mozilla.org/en/Chrome_Registration#abi
 * https://developer.mozilla.org/en/XPCOM_ABI#ABI_Naming
 *
 * See also:
 * https://bugzilla.mozilla.org/728600
 */
int main(int argc, char **argv) {
	nsresult rv;

	nsCOMPtr<nsIServiceManager> servMan;
	rv = NS_InitXPCOM2(getter_AddRefs(servMan), nullptr, nullptr);
	if (!NS_SUCCEEDED(rv)) {
		printf("init failed\n");
		return NS_ERROR_GET_CODE(rv);
	}

	nsCOMPtr<nsIXULRuntime> xulrun = do_GetService(XULAPPINFO_SERVICE_CONTRACTID, &rv);
	if (!NS_SUCCEEDED(rv)) {
		printf("get service failed\n");
		return NS_ERROR_GET_CODE(rv);
	}

	nsCString xpcomAbi;
	nsCString xpcomOs;
	rv = xulrun->GetOS(xpcomOs);
	if (!NS_SUCCEEDED(rv)) {
		printf("get os failed\n");
		return NS_ERROR_GET_CODE(rv);
	}
	rv = xulrun->GetXPCOMABI(xpcomAbi);
	if (!NS_SUCCEEDED(rv)) {
		printf("get XPCOM ABI failed\n");
		return NS_ERROR_GET_CODE(rv);
	}
	printf("%s_%s\n", xpcomOs.get(), xpcomAbi.get());

	rv = NS_ShutdownXPCOM(nullptr);
	return 0;
}
