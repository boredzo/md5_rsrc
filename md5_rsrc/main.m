#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>

int main(int argc, char *argv[]) {
	@autoreleasepool {
		NSArray <NSString *> *_Nonnull const args = [[NSProcessInfo processInfo] arguments];
		if (args.count < 2) {
			fprintf(stderr, "usage: md5_rsrc path/to/file\n");
			fprintf(stderr, "(you do not need to specify the path to the resource fork; this tool will do that for you)\n");
		} else {
			NSEnumerator <NSString *> *_Nonnull const argsEnum = [args objectEnumerator];
			[argsEnum nextObject];
			for (NSString *_Nonnull const inputFilePath in argsEnum) {
				NSFileHandle *_Nonnull const readFH = [NSFileHandle fileHandleForReadingAtPath:[inputFilePath stringByAppendingPathComponent:@"..namedfork/rsrc"]];
				CC_MD5_CTX md5Context;
				CC_MD5_Init(&md5Context);

				NSData *_Nonnull const first16 = [readFH readDataOfLength:16];
				CC_MD5_Update(&md5Context, first16.bytes, first16.length);

				[readFH readDataOfLength:128 - 16];
				NSMutableData *_Nonnull const zeroBytes = [NSMutableData dataWithLength:128 - 16];
				CC_MD5_Update(&md5Context, zeroBytes.bytes, zeroBytes.length);

				NSData *_Nullable chunk = nil;
				while ((chunk = [readFH readDataOfLength:10485760]) && chunk.length > 0) {
					CC_MD5_Update(&md5Context, chunk.bytes, chunk.length);
				}
				unsigned char md5Bytes[CC_MD5_DIGEST_LENGTH];
				CC_MD5_Final(md5Bytes, &md5Context);
				printf("%s\t%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x\n",
					inputFilePath.fileSystemRepresentation,
					md5Bytes[0], md5Bytes[1], md5Bytes[2], md5Bytes[3],
					md5Bytes[4], md5Bytes[5], md5Bytes[6], md5Bytes[7],
					md5Bytes[8], md5Bytes[9], md5Bytes[10], md5Bytes[11],
					md5Bytes[12], md5Bytes[13], md5Bytes[14], md5Bytes[15]);
			}
		}
	}
	return EXIT_SUCCESS;
}
